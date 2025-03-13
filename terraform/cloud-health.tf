#resource "google_monitoring_uptime_check_config" "https" {
#  display_name = var.name
#  timeout = "60s"
#
#  http_check {
#    path = "/"
#    port = "443"
#    use_ssl = true
#    validate_ssl = true
#    accepted_response_status_codes {
#      status_class = "STATUS_CLASS_2XX"
#      status_value = 0
#    }
#  }
#
#  monitored_resource {
#    type = "uptime_url"
#    labels = {
#      project_id = var.project_id
#      host = var.domain
#    }
#  }
#}
#
#resource "google_monitoring_alert_policy" "ft_iac_uptime_failure" {
#  display_name = "ft-iac uptime failure"
#  combiner     = "OR"
#  enabled      = true
#  severity     = "CRITICAL"
#
#  conditions {
#    display_name = "Failure of uptime check_id ft-iac-sRjoaKGSOpA"
#    condition_threshold {
#      filter     = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\""
#      duration   = "60s"
#      comparison = "COMPARISON_GT"
#      threshold_value = 1
#      
#      aggregations {
#        alignment_period   = "1200s"
#        per_series_aligner = "ALIGN_NEXT_OLDER"
#        cross_series_reducer = "REDUCE_COUNT_FALSE"
#        group_by_fields = [
#          "resource.label.project_id",
#          "resource.label.host"
#        ]
#      }
#    }
#  }
#
# notification_channels = [
#		var.notification_channels_url
# ]
#}
#