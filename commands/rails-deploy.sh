# Deploy application

#include recipe:cap-scp
#include recipe:rails-deploy
#include recipe:rails-service-puma

cap deploy
