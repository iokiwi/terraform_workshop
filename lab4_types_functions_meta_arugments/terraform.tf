terraform {
    required_version = ">= 1.4.4"
}

locals {
    # list/tuple
    backoff_squence = [1, 1, 2, 3, 5, 8, 13]

    # map/object
    adversary = {
        name = "eve"
        objective = "mischief"
    }
}


output "third_backoff_value" {
    value = local.backoff_squence[2]
}

output "backoff_values_count" {
    value = length(local.backoff_squence)
}

output "backoff_values_sum" {
    value = sum(local.backoff_squence)
}

output "unique_backoff_values" {
    value = toset(local.backoff_squence)
}

output "all_backoff_values_are_odd" {
    value = alltrue([ for s in local.backoff_squence: s % 2 == 1 ])
}

output "adversary_name" {
    value = local.adversary.name
}