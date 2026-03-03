resource "datadog_dashboard" "ec2_dashboard" {
  title       = "EC2 Monitoring Dashboard - LTI Project"
  description = "Dashboard para monitorizar instancias EC2 del proyecto LTI"
  layout_type = "ordered"

  # CPU
  widget {
    group_definition {
      title       = "CPU Metrics"
      layout_type = "ordered"

      widget {
        timeseries_definition {
          title = "CPU Utilization (%)"
          request {
            q            = "avg:aws.ec2.cpuutilization{*} by {host}"
            display_type = "line"
          }
        }
      }
    }
  }

  # Memory & Disk (requiere agente Datadog)
  widget {
    group_definition {
      title       = "System Metrics (Agent)"
      layout_type = "ordered"

      widget {
        timeseries_definition {
          title = "Memory Usage (%)"
          request {
            q            = "avg:system.mem.pct_usable{*} by {host}"
            display_type = "line"
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Disk Usage (%)"
          request {
            q            = "avg:system.disk.in_use{*} by {host,device}"
            display_type = "line"
          }
        }
      }

      widget {
        timeseries_definition {
          title = "System Load (1min)"
          request {
            q            = "avg:system.load.1{*} by {host}"
            display_type = "line"
          }
        }
      }
    }
  }

  # Network
  widget {
    group_definition {
      title       = "Network Metrics"
      layout_type = "ordered"

      widget {
        timeseries_definition {
          title = "Network In (bytes)"
          request {
            q            = "avg:aws.ec2.network_in{*} by {host}"
            display_type = "area"
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Network Out (bytes)"
          request {
            q            = "avg:aws.ec2.network_out{*} by {host}"
            display_type = "area"
          }
        }
      }
    }
  }

  # Status
  widget {
    group_definition {
      title       = "Instance Status"
      layout_type = "ordered"

      widget {
        query_value_definition {
          title = "Running Instances"
          request {
            q          = "sum:aws.ec2.host_ok{*}"
            aggregator = "last"
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Status Check Failed"
          request {
            q            = "avg:aws.ec2.status_check_failed{*} by {host}"
            display_type = "bars"
          }
        }
      }
    }
  }
}