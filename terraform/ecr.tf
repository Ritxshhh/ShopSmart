# ============================================================
# ECR — REMOVED
# AWS Academy lab policy (voc-cancel-cred) explicitly denies
# ecr:CreateRepository and ecr:DescribeRepositories.
# Docker Hub is used as the container registry instead.
# Image URLs are passed in via TF_VAR_backend_image /
# TF_VAR_frontend_image at plan time.
# ============================================================
