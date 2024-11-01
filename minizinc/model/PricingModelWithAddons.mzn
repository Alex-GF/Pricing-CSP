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
array[ADDONS, ADDONS] of int: addons_depends_on; % The position (i,j) indicates whether the add-on i depends on the addon j, which means they have to be in the same subscription

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

% Calculus of the subscription cost

constraint subscription_cost = plans_prices[selected_plan] + sum(a in ADDONS)(selected_addons[a] * addons_prices[a]);