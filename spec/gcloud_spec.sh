#shellcheck shell=sh

Describe "GCloud"
  Describe "Services"

   It "API cloudresourcemanager.googleapis.com enabled"
    When call gcloud services list --enabled
    The output should include cloudresourcemanager.googleapis.com
   End

   It "API compute.googleapis.com enabled"
    When call gcloud services list --enabled
    The output should include compute.googleapis.com
   End

   It "API iam.googleapis.com enabled"
    When call gcloud services list --enabled
    The output should include iam.googleapis.com
   End

   It "API cloudbuild.googleapis.com enabled"
    When call gcloud services list --enabled
    The output should include cloudbuild.googleapis.com
   End

   It "API containerregistry.googleapis.com API enabled"
    When call gcloud services list --enabled
    The output should include containerregistry.googleapis.com
   End

   It "API containeranalysis.googleapis.com enabled"
    When call gcloud services list --enabled
    The output should include containeranalysis.googleapis.com
   End

   It "API serviceusage.googleapis.com enabled"
    When call gcloud services list --enabled
    The output should include serviceusage.googleapis.com
   End

   It "API cloudkms.googleapis.com enabled"
    When call gcloud services list --enabled
    The output should include cloudkms.googleapis.com
   End  
       
  End

  Describe "IAM"
    iam() {
      gcloud projects get-iam-policy $(terraform output gcp_project) --format json | jq '.bindings[] | select(.role == "roles/'$1'").members[]'
    }

    # Build controller
    It "Service account $(terraform output cluster_name)-bc has the storage.objectAdmin role"
      When call iam storage.objectAdmin
      The output should include "serviceAccount:$(terraform output cluster_name)-bc@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-bc has the storage.admin role"
      When call iam storage.admin
      The output should include "serviceAccount:$(terraform output cluster_name)-bc@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    # Kaniki
    It "Service account $(terraform output cluster_name)-ko has the storage.admin role"
      When call iam storage.admin
      The output should include "serviceAccount:$(terraform output cluster_name)-ko@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    # Tekton
    It "Service account $(terraform output cluster_name)-tekton has the viewer role"
      When call iam viewer
      The output should include "serviceAccount:$(terraform output cluster_name)-tekton@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-tekton has the storage.admin role"
      When call iam storage.admin
      The output should include "serviceAccount:$(terraform output cluster_name)-tekton@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-tekton has the storage.objectAdmin role"
      When call iam storage.objectAdmin
      The output should include "serviceAccount:$(terraform output cluster_name)-tekton@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    # Vault
    It "Service account $(terraform output cluster_name)-vt has the storage.objectAdmin role"
      When call iam storage.objectAdmin
      The output should include "serviceAccount:$(terraform output cluster_name)-vt@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-vt has the cloudkms.admin role"
      When call iam cloudkms.admin
      The output should include "serviceAccount:$(terraform output cluster_name)-vt@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-vt has the cloudkms.cryptoKeyEncrypterDecrypter role"
      When call iam cloudkms.cryptoKeyEncrypterDecrypter
      The output should include "serviceAccount:$(terraform output cluster_name)-vt@$(terraform output gcp_project).iam.gserviceaccount.com"
    End  

    # DNS
    It "Service account $(terraform output cluster_name)-dn has the dns.admin role"
      When call iam dns.admin
      The output should include "serviceAccount:$(terraform output cluster_name)-dn@$(terraform output gcp_project).iam.gserviceaccount.com"
    End  

    # UI
    It "Service account $(terraform output cluster_name)-jxui has the storage.admin role"
      When call iam storage.admin
      The output should include "serviceAccount:$(terraform output cluster_name)-jxui@$(terraform output gcp_project).iam.gserviceaccount.com"
    End   

    It "Service account $(terraform output cluster_name)-jxui has the roles/storage.objectAdmin role"
      When call iam storage.objectAdmin
      The output should include "serviceAccount:$(terraform output cluster_name)-jxui@$(terraform output gcp_project).iam.gserviceaccount.com"
    End          
  End

  Describe "Storage"
    It "Bucket $(terraform output log_storage_url) for log storage has been created"
      When call gsutil ls
      The output should include $(terraform output log_storage_url)
    End

    It "Bucket $(terraform output report_storage_url) for reports storage has been created"
      When call gsutil ls
      The output should include $(terraform output report_storage_url)
    End    

    It "Bucket $(terraform output repository_storage_url) for repository storage has been created"
      When call gsutil ls
      The output should include $(terraform output repository_storage_url)
    End

    It "Bucket $(terraform output backup_bucket_url) for Velero backups has been created"
      When call gsutil ls
      The output should include $(terraform output backup_bucket_url)
    End

    It "Bucket $(terraform output vault_bucket_url) for Vault secrets has been created"
      When call gsutil ls
      The output should include $(terraform output vault_bucket_url)
    End
  End  

  Describe "Jenkins X UI service accounts"
    without_ui_sa() {
      terraform plan --var-file terraform.tfvars --var 'create_ui_sa=false' -no-color 
    }

    It "UI resources get deleted for create_ui_sa=false"
      When call without_ui_sa
      The output should include "module.cluster.google_service_account_iam_member.jxui_sa_workload_identity_user[0] will be destroyed"
      The output should include "module.cluster.google_service_account.jxui_sa[0] will be destroyed"
      The output should include "module.cluster.google_project_iam_member.ui_sa_storage_object_admin_binding[0] will be destroyed"
      The output should include "module.cluster.google_project_iam_member.ui_sa_storage_admin_binding[0] will be destroyed"
    End
  End
End
