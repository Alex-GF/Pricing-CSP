% ----------------------
% ------ RECORDS ------
% ----------------------

type UsageLimit = record(
  array[FEATURES] of int: linked_features
);

type Plan = record(
  float: price,
  array[FEATURES] of int: features,
  array[USAGE_LIMITS] of int: usage_limits
);

type AddOn = record(
  float: price,
  array[PLANS] of 0..1: available_for,
  array[ADDONS] of 0..1: depends_on,
  array[FEATURES] of int: features,
  array[USAGE_LIMITS] of int: usage_limits,
  array[USAGE_LIMITS] of int: usage_limits_extensions
);

% ----------------------
% ----- INPUT DATA -----
% ----------------------

int: unlimited = 1000000000;

enum PLANS;
enum FEATURES;
enum USAGE_LIMITS;
enum ADDONS;

array[PLANS] of Plan: plans;
array[ADDONS] of AddOn: addons;
array[USAGE_LIMITS] of UsageLimit: usage_limits;

% ---------------------
% ----- VARIABLES -----
% ---------------------

array[FEATURES] of var 0..1: subscription_features;
array[USAGE_LIMITS] of var 0..unlimited: subscription_usage_limits;

var Plan: selected_plan;

array[ADDONS] of var 0..1: selected_addons;
array[FEATURES] of var 0..1: features_included_in_selected_addons;
array[USAGE_LIMITS] of var 0..unlimited: usage_limits_included_in_selected_addons;

var float: subscription_cost;

% -----------------------
% ----- CONSTRAINTS -----
% -----------------------

% ----- Pricing consistency criteria -----

% C1: plans_features and linked_features values must be 0 or 1. plans_usage_limits values must be positive

constraint assert(forall(i in PLANS, j in FEATURES)(
  plans[i].features[j] in {0, 1}
), "Invalid datafile. All plans_features values must be 0 or 1, indicating whether a feature j is included in the plan i or not");

constraint assert(forall(i in USAGE_LIMITS, j in FEATURES)(
  usage_limits[i].linked_features[j] in {0, 1}
), "Invalid datafile. All linked_features values must be 0 or 1, indicating whether a feature j is linked to an usage_limit i or not");

constraint assert(forall(i in PLANS, j in USAGE_LIMITS)(
  plans[i].usage_limits[j] >= 0
), "Invalid datafile. All usage limits values must be positive");

% Calculus of the subscription cost

constraint subscription_cost = selected_plan.price + sum(a in ADDONS)(selected_addons[a] * addons[a].price);
