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

    It "Service account $(terraform output cluster_name)-storage has the storage.objectAdmin role"
      When call iam storage.objectAdmin
      The output should include "serviceAccount:$(terraform output cluster_name)-storage@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-ko has the storage.admin role"
      When call iam storage.admin
      The output should include "serviceAccount:$(terraform output cluster_name)-ko@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-jxboot has the dns.admin role"
      When call iam dns.admin
      The output should include "serviceAccount:$(terraform output cluster_name)-jxboot@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-jxboot has the viewer role"
      When call iam viewer
      The output should include "serviceAccount:$(terraform output cluster_name)-jxboot@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-jxboot has the iam.serviceAccountKeyAdmin role"
      When call iam iam.serviceAccountKeyAdmin
      The output should include "serviceAccount:$(terraform output cluster_name)-jxboot@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account $(terraform output cluster_name)-jxboot has the storage.admin role"
      When call iam storage.admin
      The output should include "serviceAccount:$(terraform output cluster_name)-jxboot@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

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
  End
End

Describe "K8s"
  Describe "Service Accounts"
    sa() {
      kubectl get sa $1 -n jx -o json | jq -r '.metadata.annotations["iam.gke.io/gcp-service-account"]'
    }

    It "Service account $(terraform output cluster_name)-ko has workload identity annotation"
      When call sa kaniko-sa
      The output should eq "$(terraform output cluster_name)-ko@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account tekton-bot has workload identity annotation"
      When call sa tekton-bot
      The output should eq "$(terraform output cluster_name)-storage@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account jenkins-x-controllerbuild has workload identity annotation"
      When call sa jenkins-x-controllerbuild
      The output should eq "$(terraform output cluster_name)-storage@$(terraform output gcp_project).iam.gserviceaccount.com"
    End
  End

  Describe "Workload Identity"
    workload_idenity() {
      kubectl run --rm -it --generator=run-pod/v1 --image google/cloud-sdk:slim --serviceaccount $1 --namespace jx workload-identity-test-$1 -- gcloud auth list 2>&1
    }

    It "Pod with $(terraform output cluster_name)-ko service account uses workload idenity"
      When call workload_idenity kaniko-sa
      The output should include "$(terraform output cluster_name)-ko@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Pod with tekton-bot service account uses workload idenity"
      When call workload_idenity tekton-bot
      The output should include "$(terraform output cluster_name)-storage@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Pod with jenkins-x-controllerbuild service account uses workload idenity"
      When call workload_idenity jenkins-x-controllerbuild
      The output should include "$(terraform output cluster_name)-storage@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Pod with vault-auth service account uses workload idenity"
      When call workload_idenity $(terraform output cluster_name)-vt
      The output should include "$(terraform output cluster_name)-vt@$(terraform output gcp_project).iam.gserviceaccount.com"
    End    
  End

  Describe "Storage"
    It "Bucket $(terraform output log_storage_url) for log storage has been created"
      When call gsutil ls $(terraform output log_storage_url)
      The status should be success
    End

    It "Bucket $(terraform output report_storage_url) for reports storage has been created"
      When call gsutil ls $(terraform output report_storage_url)
      The status should be success
    End    

    It "Bucket $(terraform output repository_storage_url) for repository storage has been created"
      When call gsutil ls $(terraform output repository_storage_url)
      The status should be success
    End
  End  
End
