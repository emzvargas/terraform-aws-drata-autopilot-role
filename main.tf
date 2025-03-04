data "aws_iam_policy_document" "drata_autopilot_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.drata_aws_account_arn]
    }

    dynamic "condition" {
      for_each = var.role_sts_externalid != null ? [true] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.role_sts_externalid]
      }
    }
  }
}
resource "aws_iam_role" "drata" {
  name        = var.role_name
  path        = var.role_path
  description = var.role_description

  assume_role_policy = data.aws_iam_policy_document.drata_autopilot_assume_role.json

  tags = var.tags
}

#resource "aws_iam_role_policy_attachment" "security_audit" {
#  role       = aws_iam_role.drata.name
#  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
#}

data "aws_iam_policy_document" "drata_additional_permissions" {
  for_each = var.drata_additional_inline_policies

  dynamic "statement" {
    for_each = each.value
    content {
      sid       = try(statement.value.sid, null) == null ? null : statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = toset(try(statement.value.conditions, null) == null ? [] : statement.value.conditions)
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "drata_additional_permissions" {
  for_each = var.drata_additional_inline_policies

  name   = each.key
  role   = aws_iam_role.drata.name
  policy = data.aws_iam_policy_document.drata_additional_permissions[each.key].json
}

resource "aws_iam_role_policy_attachment" "drata_additional_policy_attachments" {
  for_each = var.drata_additional_policy_arns

  role       = aws_iam_role.drata.name
  policy_arn = each.value
}
