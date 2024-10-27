% ----------------------
% ----- INPUT DATA -----
% ----------------------

int: unlimited = 1000000000;

enum FEATURES;
enum USAGE_LIMITS;
enum ADDONS;

array[ADDONS] of float: addons_prices; % The position i indicates the price of an add-on.

array[USAGE_LIMITS, FEATURES] of int: linked_features; % The position (i,j) indicates wether the usageLimit i is linked to the feature j

array[ADDONS, FEATURES] of int: addons_features; % The position (i,j) indicates wether the add-on i includes the feature j
array[ADDONS, USAGE_LIMITS] of int: addons_usage_limits; % The position (i,j) indicates the value of the usage limit j in the add-on i.
array[ADDONS, USAGE_LIMITS] of int: addons_usage_limits_extensions; % The position (i,j) indicates the extension of the limit imposed by the usage limit j in the subscription when contracting the add-on i.

% ---------------------
% ----- VARIABLES -----
% ---------------------

array[FEATURES] of var 0..1: subscription_features;
array[USAGE_LIMITS] of var 0..unlimited: subscription_usage_limits;

array[ADDONS] of var 0..1: selected_addons;

var float: subscription_cost;

% -----------------------
% ----- CONSTRAINTS -----
% -----------------------

% ----- Pricing consistency criteria -----

% C1: plans_features and linked_features values must be 0 or 1. plans_usage_limits values must be positive

constraint assert(forall(i in ADDONS, j in FEATURES)(
  addons_features[i,j] in {0, 1}
), "Invalid datafile. All addons_features values must be 0 or 1, indicating whether a feature j is included in the add-on i or not");

constraint assert(forall(i in USAGE_LIMITS, j in FEATURES)(
  linked_features[i,j] in {0, 1}
), "Invalid datafile. All linked_features values must be 0 or 1, indicating whether a feature j is linked to an usage_limit i or not");

constraint assert(forall(i in ADDONS, j in USAGE_LIMITS)(
  addons_usage_limits[i,j] >= 0
), "Invalid datafile. All addons_usage_limits values must be non-negative, indicating the value of the usage limit j in the add-on i");

% C2: All features linked to a usage limit included within a plan are afected by its restriction.

constraint assert(forall(i in ADDONS, j in FEATURES, k in USAGE_LIMITS)(
  if linked_features[k,j] == 1 /\ addons_features[i,j] == 1
    then addons_usage_limits[i,k] > 0
  endif
), "Invalid datafile. The value of all usage limits whose linked_features are in an add-on must be > 0");

% C3: The subscription must have, at least, one addon selected.

constraint sum(a in ADDONS)(selected_addons[a]) >= 1;

% C4: All the features included within the subscription must correspond to a combination of 1..n add-ons.

constraint forall(a in ADDONS, f in FEATURES)(
 if selected_addons[a] = 1 
    then if subscription_features[f] = 0 
        then subscription_features[f] = addons_features[a,f]
    endif
 endif
);

constraint forall(u in USAGE_LIMITS)(
    subscription_usage_limits[u] = 
        max(a in ADDONS)(if selected_addons[a] = 1 then addons_usage_limits[a, u] else 0 endif)
        +
        sum(a in ADDONS)(if selected_addons[a] = 1 then addons_usage_limits_extensions[a, u] else 0 endif)
);

% Calculus of the subscription cost

constraint subscription_cost = sum(a in ADDONS)(selected_addons[a] * addons_prices[a]);

output [
  "Selected addons = ", show(selected_addons), "\n",
  "Features included in subscription = ", show(subscription_features), "\n",
  "Usage Limits included in subscription = ", show(subscription_usage_limits), "\n",
  "Subscription cost = ", show(subscription_cost)
];