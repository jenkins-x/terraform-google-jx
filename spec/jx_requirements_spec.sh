#shellcheck shell=sh

Describe 'jx-requirements'
  It 'jx-requirements contains cluster name'
    When call yq r jx-requirements.yml 'cluster.clusterName'
    The output should eq $(terraform output cluster_name)
  End 

  It 'jx-requirements contains ingress section'
    When call yq r jx-requirements.yml 'ingress'
    The output should start with "domain"
  End 
End
