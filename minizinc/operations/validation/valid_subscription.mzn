include "./valid_pricing.mzn";

% C4: All the features included within the subscription must correspond to a combination of one plan and 0..n add-ons.

constraint
  if num_addons > 0 
    then forall(a in ADDONS, f in FEATURES)(
      features_included_in_selected_addons[f] = max(a in ADDONS)(selected_addons[a] * addons_features[a, f])
    )
  endif;

constraint
  if num_usage_limits > 0
    then forall(u in USAGE_LIMITS)(
      if num_addons > 0 
        then
          usage_limits_included_in_selected_ADDONS[u] = 
              max(a in ADDONS)(if selected_addons[a] = 1 then addons_usage_limits[a, u] else 0 endif)
              +
              sum(a in ADDONS)(if selected_addons[a] = 1 then addons_usage_limits_extensions[a, u] else 0 endif)
        else
          usage_limits_included_in_selected_ADDONS[u] = 0
      endif
    )
  endif;

constraint forall(f in FEATURES)(
  subscription_features[f] = (plans_features[selected_plan, f] == 1 \/ features_included_in_selected_addons[f] == 1)
);

constraint
  if num_usage_limits > 0
    then forall(u in USAGE_LIMITS)(
      subscription_usage_limits[u] = plans_usage_limits[selected_plan, u] + usage_limits_included_in_selected_ADDONS[u]
    )
  endif;

% C5: All selected add_ons must be available for the selected plan

constraint
  if num_addons > 0
    then forall(i in ADDONS)(
      addons_available_for[i, selected_plan] == 1
    )
  endif;

% C6: The subscription must included all dependent addons

constraint
  if num_addons > 0
    then forall(i in ADDONS, j in ADDONS)(
      if addons_depends_on[i, j] == 1 then selected_addons[i] == 1 -> selected_addons[j] == 1 endif
    )
  endif;