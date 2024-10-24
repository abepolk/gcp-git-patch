# To be sourced, not sh'ed

$METADATA_URI='http://metadata.google.internal/computeMetadata/v1/project/startup-script'

apply_saved_patch () {
    BUCKET_NAME="$(curl $METADATA_URI -H 'Metadata-Flavor: Google')"
    gsutil cp "gs://$BUCKET_NAME/$1.patch" - | git apply -
}

save_patch () { # BE CAREFUL, THIS OVERWRITES
    BUCKET_NAME="$(curl $METADATA_URI -H 'Metadata-Flavor: Google')"
    git diff | gsutil cp - gs://$BUCKET_NAME/$1.patch 
}
