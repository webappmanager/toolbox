# Restart puma

#include recipe:rails-service-puma
#include recipe:rails-deploy

cap puma:restart