# Gets the metadata item that has the backend bucket name, and tells terraform that
# we are creating the backend in that bucket
terraform init -backend-config="bucket=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[terraform_state_bucket_name])")"
