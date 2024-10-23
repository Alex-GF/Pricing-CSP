% ----------------------
% ----- INPUT DATA -----
% ----------------------

int: unlimited = 1000000000;

enum PLANS;
enum FEATURES;
enum USAGE_LIMITS;
enum ADDONS;

array[PLANS] of float: plans_prices; % The position i indicates the price of a plan.
array[ADDONS] of float: addons_prices; % The position i indicates the price of an add-on.

array[PLANS, FEATURES] of int: plans_features; % The position (i,j) indicates wether the plan i includes the feature j
array[PLANS, USAGE_LIMITS] of int: plans_usage_limits; % The position (i,j) indicates the value of the usage limit j in the plan i.

array[USAGE_LIMITS, FEATURES] of int: linked_features; % The position (i,j) indicates wether the usageLimit i is linked to the feature j

array[ADDONS, FEATURES] of int: addons_features; % The position (i,j) indicates wether the add-on i includes the feature j
array[ADDONS, USAGE_LIMITS] of int: addons_usage_limits; % The position (i,j) indicates the value of the usage limit j in the add-on i.
array[ADDONS, USAGE_LIMITS] of int: addons_usage_limits_extensions; % The position (i,j) indicates the extension of the limit imposed by the usage limit j in the subscription when contracting the add-on i.
array[ADDONS, PLANS] of int: addons_available_for; % The position (i,j) indicates whether the add-on i is available for the plan j

% ---------------------
% ----- VARIABLES -----
% ---------------------

array[FEATURES] of var 0..1: subscription_features;
array[USAGE_LIMITS] of var 0..unlimited: subscription_usage_limits;

var PLANS: selected_plan;

array[ADDONS] of var 0..1: selected_addons;
array[FEATURES] of var 0..1: features_included_in_selected_addons;
array[USAGE_LIMITS] of var 0..unlimited: usage_limits_included_in_selected_ADDONS;

var float: subscription_cost;

% -----------------------
% ----- CONSTRAINTS -----
% -----------------------

% ----- Pricing consistency criteria -----

% C1: plans_features and linked_features values must be 0 or 1. plans_usage_limits values must be positive

constraint assert(forall(i in PLANS, j in FEATURES)(
  plans_features[i,j] in {0, 1}
), "Invalid datafile. All plans_features values must be 0 or 1, indicating whether a feature j is included in the plan i or not");

constraint assert(forall(i in USAGE_LIMITS, j in FEATURES)(
  linked_features[i,j] in {0, 1}
), "Invalid datafile. All linked_features values must be 0 or 1, indicating whether a feature j is linked to an usage_limit i or not");

constraint assert(forall(i in PLANS, j in USAGE_LIMITS)(
  plans_usage_limits[i,j] >= 0
), "Invalid datafile. All usage limits values must be positive");

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

% C4: All the features included within the subscription must correspond to a combination of one plan and 0..n add-ons.

constraint forall(a in ADDONS, f in FEATURES)(
 if selected_addons[a] = 1 then features_included_in_selected_addons[f] = addons_features[a,f] endif
);

constraint forall(a in ADDONS, u in USAGE_LIMITS)(
 if selected_addons[a] = 1 then usage_limits_included_in_selected_ADDONS[u] = addons_usage_limits[a,u] + addons_usage_limits_extensions[a,u] endif
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

% Calculus of the subscription cost

constraint subscription_cost = plans_prices[selected_plan] + sum(a in ADDONS)(selected_addons[a] * addons_prices[a]);

solve satisfy;

output [
  "Selected plan = ", show(selected_plan), "\n",
  "Selected addons = ", show(selected_addons), "\n",
  "Features included in subscription = ", show(subscription_features), "\n",
  "Usage Limits included in subscription = ", show(subscription_usage_limits), "\n",
  "Subscription cost = ", show(subscription_cost)
];