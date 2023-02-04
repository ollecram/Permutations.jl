using Logging

# Create a ConsoleLogger that prints any log messages with level >= Debug to stderr
debuglogger = ConsoleLogger(stderr, Logging.Debug)

# Set the global ConsoleLogger
global_logger(debuglogger)