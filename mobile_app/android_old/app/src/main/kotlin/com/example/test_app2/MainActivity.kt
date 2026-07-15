package com.example.test_app2

import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.permission.PermissionController
import androidx.health.connect.client.records.BloodPressureRecord
import androidx.health.connect.client.records.OxygenSaturationRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.Instant

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "pytha_health_connect_vitals"

    private lateinit var permissionLauncher: ActivityResultLauncher<Set<String>>
    private var pendingPermissionResult: MethodChannel.Result? = null

    private val vitalPermissions: Set<String>
        get() = setOf(
            HealthPermission.getReadPermission(BloodPressureRecord::class),
            HealthPermission.getReadPermission(OxygenSaturationRecord::class)
        )

    override fun onCreate(savedInstanceState: Bundle?) {
        permissionLauncher = registerForActivityResult(
            PermissionController.createRequestPermissionResultContract()
        ) { grantedPermissions ->
            val granted = vitalPermissions.all { permission ->
                grantedPermissions.contains(permission)
            }

            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }

        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestVitalsPermissions" -> requestVitalsPermissions(result)

                "readVitals" -> {
                    val startMillis = call.argument<Long>("startMillis")
                    val endMillis = call.argument<Long>("endMillis")

                    if (startMillis == null || endMillis == null) {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "startMillis and endMillis are required",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    readVitals(startMillis, endMillis, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun isHealthConnectAvailable(): Boolean {
        val status = HealthConnectClient.getSdkStatus(this)
        return status == HealthConnectClient.SDK_AVAILABLE
    }

    private fun requestVitalsPermissions(result: MethodChannel.Result) {
        if (!isHealthConnectAvailable()) {
            result.error(
                "HEALTH_CONNECT_NOT_AVAILABLE",
                "Health Connect is not available on this device",
                null
            )
            return
        }

        CoroutineScope(Dispatchers.Main).launch {
            try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)

                val granted = withContext(Dispatchers.IO) {
                    client.permissionController.getGrantedPermissions()
                }

                val alreadyGranted = vitalPermissions.all { permission ->
                    granted.contains(permission)
                }

                if (alreadyGranted) {
                    result.success(true)
                    return@launch
                }

                if (pendingPermissionResult != null) {
                    result.error(
                        "PERMISSION_REQUEST_RUNNING",
                        "Another Health Connect permission request is already running",
                        null
                    )
                    return@launch
                }

                pendingPermissionResult = result
                permissionLauncher.launch(vitalPermissions)
            } catch (e: Exception) {
                result.error(
                    "PERMISSION_ERROR",
                    e.message ?: "Could not request Health Connect permissions",
                    null
                )
            }
        }
    }

    private fun readVitals(
        startMillis: Long,
        endMillis: Long,
        result: MethodChannel.Result
    ) {
        if (!isHealthConnectAvailable()) {
            result.error(
                "HEALTH_CONNECT_NOT_AVAILABLE",
                "Health Connect is not available on this device",
                null
            )
            return
        }

        CoroutineScope(Dispatchers.Main).launch {
            try {
                val client = HealthConnectClient.getOrCreate(this@MainActivity)

                val granted = withContext(Dispatchers.IO) {
                    client.permissionController.getGrantedPermissions()
                }

                val missing = vitalPermissions.filter { permission ->
                    !granted.contains(permission)
                }

                if (missing.isNotEmpty()) {
                    result.error(
                        "MISSING_PERMISSIONS",
                        "Blood Pressure / Oxygen permissions are missing",
                        missing
                    )
                    return@launch
                }

                val start = Instant.ofEpochMilli(startMillis)
                val end = Instant.ofEpochMilli(endMillis)

                val bloodPressureRecords = withContext(Dispatchers.IO) {
                    client.readRecords(
                        ReadRecordsRequest(
                            recordType = BloodPressureRecord::class,
                            timeRangeFilter = TimeRangeFilter.between(start, end)
                        )
                    ).records
                }

                val oxygenRecords = withContext(Dispatchers.IO) {
                    client.readRecords(
                        ReadRecordsRequest(
                            recordType = OxygenSaturationRecord::class,
                            timeRangeFilter = TimeRangeFilter.between(start, end)
                        )
                    ).records
                }

                val latestBloodPressure = bloodPressureRecords.maxByOrNull { it.time }
                val latestOxygen = oxygenRecords.maxByOrNull { it.time }

                val response = HashMap<String, Any?>()

                if (latestBloodPressure != null) {
                    response["blood_pressure_systolic"] =
                        latestBloodPressure.systolic.inMillimetersOfMercury
                    response["blood_pressure_diastolic"] =
                        latestBloodPressure.diastolic.inMillimetersOfMercury
                    response["blood_pressure_time"] =
                        latestBloodPressure.time.toEpochMilli()
                }

                if (latestOxygen != null) {
                    response["oxygen_saturation"] =
                        latestOxygen.percentage.value
                    response["oxygen_time"] =
                        latestOxygen.time.toEpochMilli()
                }

                result.success(response)
            } catch (e: Exception) {
                result.error(
                    "READ_VITALS_ERROR",
                    e.message ?: "Could not read Blood Pressure / Oxygen data",
                    null
                )
            }
        }
    }
}
