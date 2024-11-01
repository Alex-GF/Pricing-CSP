include "./valid_pricing.mzn";

% C4: All the features included within the subscription must correspond to a combination of one plan and 0..n add-ons.

constraint forall(a in ADDONS, f in FEATURES)(
  features_included_in_selected_addons[f] = max(a in ADDONS)(selected_addons[a] * addons_features[a, f])
);

constraint forall(u in USAGE_LIMITS)(
    usage_limits_included_in_selected_ADDONS[u] = 
        max(a in ADDONS)(if selected_addons[a] = 1 then addons_usage_limits[a, u] else 0 endif)
        +
        sum(a in ADDONS)(if selected_addons[a] = 1 then addons_usage_limits_extensions[a, u] else 0 endif)
);

constraint forall(f in FEATURES)(
  subscription_features[f] = (plans_features[selected_plan, f] == 1 \/ features_included_in_selected_addons[f] == 1)
);

constraint forall(u in USAGE_LIMITS)(
  subscription_usage_limits[u] = plans_usage_limits[selected_plan, u] + usage_limits_included_in_selected_ADDONS[u]
);

% C5: All selected add_ons must be available for the selected plan

constraint forall(i in ADDONS)(
  addons_available_for[i, selected_plan] == 1
);

% C6: The subscription must included all dependent addons

constraint forall(i in ADDONS, j in ADDONS)(
  if addons_depends_on[i, j] == 1 then selected_addons[i] == 1 -> selected_addons[j] == 1 endif
);