#shellcheck shell=sh

Describe "Kubernetes"
  Describe "Service Accounts"
    service_account_get_annotation() {
      kubectl get sa $1 -n $2 -o json | jq -r '.metadata.annotations["iam.gke.io/gcp-service-account"]'
    }

    # Kaniko
    It "Service account kaniko-sa has workload identity annotation"
      When call service_account_get_annotation kaniko-sa jx
      The output should eq "$(terraform output cluster_name)-ko@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    # Tekton
    It "Service account tekton-bot has workload identity annotation"
      When call service_account_get_annotation tekton-bot jx
      The output should eq "$(terraform output cluster_name)-tekton@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    # Build controller
    It "Service account jenkins-x-controllerbuild has workload identity annotation"
      When call service_account_get_annotation jenkins-x-controllerbuild jx
      The output should eq "$(terraform output cluster_name)-bc@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    # DNS
    It "Service account exdns-external-dns has workload identity annotation"
      When call service_account_get_annotation exdns-external-dns jx
      The output should eq "$(terraform output cluster_name)-dn@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account cm-cert-manager has workload identity annotation"
      When call service_account_get_annotation cm-cert-manager cert-manager
      The output should eq "$(terraform output cluster_name)-dn@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Service account cm-cainjector has workload identity annotation"
      When call service_account_get_annotation cm-cainjector cert-manager
      The output should eq "$(terraform output cluster_name)-dn@$(terraform output gcp_project).iam.gserviceaccount.com"
    End    

    # Vault
    It "Service account $(terraform output cluster_name)-vt has workload identity annotation"
      When call service_account_get_annotation $(terraform output cluster_name)-vt jx
      The output should eq "$(terraform output cluster_name)-vt@$(terraform output gcp_project).iam.gserviceaccount.com"
    End 

    # Velero
    It "Service account velero-server has workload identity annotation"
      When call service_account_get_annotation velero-server velero
      The output should eq "$(terraform output cluster_name)-vo@$(terraform output gcp_project).iam.gserviceaccount.com"
    End  

    # UI
    It "Service account jxui has workload identity annotation"
      When call service_account_get_annotation jxui-sa jx
      The output should eq "$(terraform output cluster_name)-jxui@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

  End

  Describe "Workload Identity"
    workload_identity_test() {
      kubectl run -n $2 --generator=job/v1 --restart=Never --image google/cloud-sdk:slim --serviceaccount $1 workload-identity-test-$1 -- gcloud auth list 2> /dev/null
      kubectl wait -n $2 --timeout=60s --for=condition=complete job/workload-identity-test-$1
      kubectl logs -n $2 job/workload-identity-test-$1
      kubectl delete -n $2 job/workload-identity-test-$1
    }

    It "Pod with $(terraform output cluster_name)-ko service account uses workload identity"
      When call workload_identity_test kaniko-sa jx
      The output should include "$(terraform output cluster_name)-ko@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Pod with tekton-bot service account uses workload identity"
      When call workload_identity_test tekton-bot jx
      The output should include "$(terraform output cluster_name)-tekton@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Pod with jenkins-x-controllerbuild service account uses workload identity"
      When call workload_identity_test jenkins-x-controllerbuild jx
      The output should include "$(terraform output cluster_name)-bc@$(terraform output gcp_project).iam.gserviceaccount.com"
    End

    It "Pod with vault-auth service account uses workload identity"
      When call workload_identity_test $(terraform output cluster_name)-vt jx
      The output should include "$(terraform output cluster_name)-vt@$(terraform output gcp_project).iam.gserviceaccount.com"
    End    

    It "Pod with velero-server service account uses workload identity"
      When call workload_identity_test velero-server velero
      The output should include "$(terraform output cluster_name)-vo@$(terraform output gcp_project).iam.gserviceaccount.com"
    End  

    It "Pod with cm-cert-manager service account uses workload identity"
      When call workload_identity_test cm-cert-manager cert-manager
      The output should include "$(terraform output cluster_name)-dn@$(terraform output gcp_project).iam.gserviceaccount.com"
    End  

    It "Pod with cm-cainjector service account uses workload identity"
      When call workload_identity_test cm-cainjector cert-manager
      The output should include "$(terraform output cluster_name)-dn@$(terraform output gcp_project).iam.gserviceaccount.com"
    End  

    It "Pod with exdns-external-dns service account uses workload identity"
      When call workload_identity_test exdns-external-dns jx
      The output should include "$(terraform output cluster_name)-dn@$(terraform output gcp_project).iam.gserviceaccount.com"
    End    

    It "Pod with jxui service account uses workload identity"
      When call workload_identity_test jxui jx
      The output should include "$(terraform output cluster_name)-jxui@$(terraform output gcp_project).iam.gserviceaccount.com"
    End          
  End

  Describe "Cluster"
    get_resource_label() {
      gcloud container clusters describe $(terraform output cluster_name)  --zone $(terraform output cluster_location) | yq r - 'resourceLabels['$1']'
    }

    It "The cluster has resource labels"
      When call get_resource_label "powered-by"
      The output should eq "jenkins-x"
    End
  End
End
