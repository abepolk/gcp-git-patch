terraform {
    # Backend is local by default in Terraform
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "4.78.0"
        }
    }
    required_version = "~> 1.5.5"
    # The only information to configure the backend is the bucket name,
    # and we are getting that from project metadata and passing in through
    # the CLI. Here we just say which backend we are using.
    backend "gcs" {}
}

# This should be supplied from the command line via
# the terraform-<operation>-wrapper.sh one-line (for now) scripts.
# Except the terraform_init_wrapper.sh script.
# Do not enter interactively

variable "project_id" {
    type = string
}

variable "location" {
    type = string
}

locals {
    git_patch_bucket_base_name = "git-patch-bucket"
}

provider "google" {
    project = var.project_id
    # No zone or region here because region and zone defined in
    # provider generally apply only to Compute and possibly a few
    # more esoteric services, and we are only using Compute outside of Terraform.
}

resource "random_id" "git_patch_bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "git_patch_bucket" {
    name = "${random_id.git_patch_bucket_prefix.hex}-${local.git_patch_bucket_base_name}"
    location = var.location
    storage_class = "STANDARD"
    # uniform_bucket_level_access disables ACLs, which are only useful
    # in legacy contexts and migrations from AWS
    uniform_bucket_level_access = true
}

resource "google_compute_project_metadata_item" "git_patch_bucket_name" {
    key = "git_patch_bucket_name"
    value = "${random_id.git_patch_bucket_prefix.hex}-${local.git_patch_bucket_base_name}"
}

resource "google_compute_project_metadata_item" "git_patch_bucket_name" {
    key = "startup-script"
    value = file("${path.module}/set_up_functions.sh")