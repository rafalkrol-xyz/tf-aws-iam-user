output "aws_iam_user_credentials" {
  description = "The credentials of a given IAM user"
  value = {
    name                        = var.create_aws_iam_user ? element(aws_iam_user.this.*.name, 0) : null
    encrypted_password          = var.create_aws_iam_user_login_profile ? element(aws_iam_user_login_profile.this.*.encrypted_password, 0) : null
    pgp_key                     = var.pgp_key
    access-key-id               = var.create_aws_iam_access_key ? element(aws_iam_access_key.this.*.id, 0) : null
    encrypted-secret-access-key = var.create_aws_iam_access_key ? element(aws_iam_access_key.this.*.encrypted_secret, 0) : null
  }

  # The below is just a safety precaution against an apparent race condition when creating the above output
  depends_on = [
    aws_iam_user.this,
    aws_iam_user_login_profile.this,
    aws_iam_access_key.this,
  ]
}
