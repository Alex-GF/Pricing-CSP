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

type Subscription = record(
  PLANS: selected_plan,
  array[ADDONS] of 0..1: selected_addons,
  array[FEATURES] of 0..1: features_included_in_selected_addons,
  array[USAGE_LIMITS] of 0..unlimited: usage_limits_included_in_selected_addons,
  array[FEATURES] of 0..1: features,
  array[USAGE_LIMITS] of 0..unlimited: usage_limits,
  float: subscription_cost
);

% ----------------------
% ----- INPUT DATA -----
% ----------------------

int: unlimited = 1000000000;

enum FEATURES;
enum USAGE_LIMITS;
enum PLANS;
enum ADDONS;

array[USAGE_LIMITS] of UsageLimit: usage_limits;
array[PLANS] of Plan: plans;
array[ADDONS] of AddOn: addons;

% ----------------------
% ----- VARIABLES -----
% ----------------------

var Subscription: subscription;

% -----------------------
% ----- CONSTRAINTS -----
% -----------------------

% ----- Pricing consistency criteria -----

% C1: plans_features and linked_features values must be 0 or 1. plans_usage_limits values must be positive

% constraint assert(forall(p in PLANS, f in FEATURES)(
%   plans[p].features[f] in {0, 1}
% ), "Invalid datafile. All plans_features values must be 0 or 1, indicating whether a feature j is included in the plan i or not");

% constraint assert(forall(u in USAGE_LIMITS, f in FEATURES)(
%   usage_limits[u].linked_features[f] in {0, 1}
% ), "Invalid datafile. All linked_features values must be 0 or 1, indicating whether a feature j is linked to an usage_limit i or not");

% constraint assert(forall(p in PLANS, u in USAGE_LIMITS)(
%   plans[p].usage_limits[u] >= 0
% ), "Invalid datafile. All usage limits values must be positive");

% Calculus of the subscription cost

% constraint subscription.subscription_cost = subscription.selected_plan.price + sum(a in ADDONS)(subscription.selected_addons[a] * addons[a].price);