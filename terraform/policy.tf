#
# policy.tf
#

resource "oci_identity_dynamic_group" "dyngrp_instance" {
   compartment_id = var.tenancy_id

    name = "dyngrp-instance"
    description = "Grupo dinâmico que inclui as instâncias de computação do compartimento especificado."

    matching_rule = "All {instance.compartment.id = '${var.root_compartment}'}"
}

resource "oci_identity_policy" "proj-ocipizza_policies" {    
    compartment_id = var.tenancy_id

    name = "ocipizza_iam-policy-1"
    description = "Política IAM que permite a instância de computação acessar objetos no bucket e ler componentes de rede."

    statements = [    
       "Allow dynamic-group ${oci_identity_dynamic_group.dyngrp_instance.name} to read buckets in compartment id ${var.root_compartment} where target.bucket.name='${module.gru_objectstorage_bucket_scripts-storage.bucket_name}'",
       "Allow dynamic-group ${oci_identity_dynamic_group.dyngrp_instance.name} to read objects in compartment id ${var.root_compartment} where target.bucket.name='${module.gru_objectstorage_bucket_scripts-storage.bucket_name}'",
       "Allow dynamic-group ${oci_identity_dynamic_group.dyngrp_instance.name} to manage virtual-network-family in compartment id ${var.root_compartment}",
       "Allow dynamic-group ${oci_identity_dynamic_group.dyngrp_instance.name} to read instance-family in compartment id ${var.root_compartment}"
    ]
}