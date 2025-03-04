variable "drata_aws_account_arn" {
  type        = string
  default     = "arn:aws:iam::269135526815:root"
  description = "Drata's AWS account ARN"
}

variable "role_sts_externalid" {
  description = "STS ExternalId condition value to use with the role"
  type        = string
  default     = null
}

variable "role_name" {
  description = "IAM role name"
  type        = string
  default     = "DrataAutopilotRole"
}

variable "role_path" {
  description = "Path of IAM role (we currently do not support a path other than '/')"
  type        = string
  default     = "/"
}

variable "role_description" {
  description = "IAM Role description"
  type        = string
  default     = "Cross-account read-only access for Drata Autopilot"
}

variable "tags" {
  description = "A map of tags to add to IAM role resources"
  type        = map(string)
  default     = {}
}

variable "drata_additional_inline_policies" {
  description = "Additional permissions to add to the IAM role"
  type = map(list(object({
    sid       = optional(string)
    effect    = string
    actions   = list(string)
    resources = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  })))
  default = {
    BackupPermissions = [{
      effect = "Allow"
      actions = [
        "backup:ListBackupJobs",
        "backup:ListRecoveryPointsByResource"
      ]
      resources = [
        "*"
      ]
    }]
  }
}

variable "drata_additional_policy_arns" {
  description = "Map of IAM policies ARNs to attach to the Drata role"
  type        = map(string)
  default = {
    "SecurityAudit" = "arn:aws:iam::aws:policy/SecurityAudit"
  }
}
