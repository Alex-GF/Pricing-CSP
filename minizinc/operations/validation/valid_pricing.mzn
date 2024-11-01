include "../../model/PricingModelWithAddons.mzn";

% C2: All features linked to a usage limit included within a plan are afected by its restriction.

constraint assert(forall(i in PLANS, j in FEATURES, k in USAGE_LIMITS)(
  if linked_features[k,j] == 1 /\ plans_features[i,j] == 1
    then plans_usage_limits[i,k] > 0
  endif
), "Invalid datafile. The value of all usage limits whose linked_features are in a plan must be > 0");

% C3: All add-ons must be available for, at least, one plan

constraint forall(i in ADDONS)(
  sum(j in PLANS)(addons_available_for[i,j]) > 0
);