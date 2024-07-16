import os

def inner_handler(event, context, my_env):
    if my_env == "PROD":
        print("We are running app on PRODUCTION ENVIRONMENT")
    elif my_env == "STAGING":
        print("We are running app on STAGING ENVIRONMENT")
    else:
        print("We are running app on DEVELOPMENT ENVIRONMENT")

def outer_handler(event, context):
    environment = os.environ.get('ENV', 'DEV')  # here we are setting DEV as default environment 
    return inner_handler(event, context, environment)
