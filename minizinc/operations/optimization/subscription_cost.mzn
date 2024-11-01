include "../validation/valid_subscription.mzn";

% ----------------------
% ----- INPUT DATA -----
% ----------------------

array[FEATURES] of int: requested_features; % The position i indicates wether the feature i must be in the subscription.
array[USAGE_LIMITS] of int: requested_usage_limits; % The position i indicates wether the usage limit i must be in the subscription.

% ----------------------
% ----- CONSTRAINTS -----
% ----------------------

% Check the format of the datafile
constraint assert(forall(i in FEATURES)(
  requested_features[i] in {0, 1}
), "Invalid datafile. All requested_features values must be 0 or 1, indicating whether the feature i must be included within the subscription or not");

% All features and usage limits must be satisfied by the subscription
constraint forall(i in FEATURES)(
  subscription_features[i] >= requested_features[i]
);

constraint forall(i in USAGE_LIMITS)(
  subscription_usage_limits[i] >= requested_usage_limits[i]
);

% Solve
solve minimize subscription_cost;

output [
  "Selected plan = ", show(selected_plan), "\n",
  "Selected addons = ", show(selected_addons), "\n",
  "Features included in subscription = ", show(subscription_features), "\n",
  "Usage Limits included in subscription = ", show(subscription_usage_limits), "\n",
  "Subscription cost = ", show(subscription_cost)
];