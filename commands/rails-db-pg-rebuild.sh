#WARNING: Rebuilds current application database!  All data will be lost!

#include recipe:rails-deploy
#include recipe:rails-db-pg

cap db:pg:rebuild