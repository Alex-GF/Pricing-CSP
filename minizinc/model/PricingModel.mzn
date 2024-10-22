% ----------------------
% ----- INPUT DATA -----
% ----------------------

int: unlimited = 1000000000;

enum PLANS;
enum FEATURES;
enum USAGE_LIMITS;

array[PLANS] of float: plans_prices; % The position i indicates the price of a plan.
% array[ADD_ONS] of float: addons_prices; % The position i indicates the price of an add-on.
array[PLANS, FEATURES] of int: plans_features; % The position (i,j) indicates wether the plan i includes the feature j
array[PLANS, USAGE_LIMITS] of int: plans_usage_limits; % The position (i,j) indicates the value of the usage limit j in the plan i.
array[USAGE_LIMITS, FEATURES] of int: linked_features; % The position (i,j) indicates wether the usageLimit i is linked to the feature j

% ---------------------
% ----- VARIABLES -----
% ---------------------

array[FEATURES] of var 0..1: subscription_features;
array[USAGE_LIMITS] of var 0..unlimited: subscription_usage_limits;
var PLANS: selected_plan;
% array[ADD_ONS] of var 0..1: selected_addons;
% array[FEATURES] of var 0..1: features_included_in_selected_addons;
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

% C3: All the features included within the subscription must correspond to a combination of one plan and 0..n add-ons.

constraint forall(f in FEATURES)(
  subscription_features[f] = plans_features[selected_plan, f]
);

constraint forall(f in FEATURES, u in USAGE_LIMITS)(
  subscription_usage_limits[u] = plans_usage_limits[selected_plan, u]
);

%constraint forall(a in ADDONS, f in FEATURES)(
%  if selected_addons[a] = 1 then %features_included_in_selected_addons[f] = 
%)

% Calculus of the subscription cost

constraint subscription_cost = plans_prices[selected_plan]; % + sum(a in ADDONS)(selected_addons[a] * addons_prices[a])