include "../../model/2.0/PricingModelWithAddons-test.mzn";

% C2: All features linked to a usage limit included within a plan are afected by its restriction.

% constraint assert(forall(p in PLANS, f in FEATURES, u in USAGE_LIMITS)(
%   if usage_limits[u].linked_features[f] == 1 /\ plans[p].features[f] == 1
%     then plans[p].usage_limits[u] > 0
%   endif
% ), "Invalid datafile. The value of all usage limits whose linked_features are in a plan must be > 0");

% C3: All add-ons must be available for, at least, one plan

constraint forall(a in ADDONS)(
  sum(p in PLANS)(addons[a].available_for[p]) > 0
);