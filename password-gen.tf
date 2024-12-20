##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "random_password" "randompass" {
  for_each         = var.users
  length           = 20
  special          = false
  override_special = "=_-"
  min_upper        = 2
  min_special      = 0
  min_numeric      = 2
  min_lower        = 2

  lifecycle {
    replace_triggered_by = [
      time_rotating.randompass[each.key].rotation_rfc3339
    ]
  }
}

resource "time_rotating" "randompass" {
  for_each      = var.users
  rotation_days = try(each.value.password_rotation_period, 90)
}
