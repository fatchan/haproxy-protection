function set_tfp_var(txn)
    txn:set_var('txn.fp_custom', 'changeme')
end

core.register_action('set_tfp', {'tcp-req', 'http-req'}, set_tfp_var)
