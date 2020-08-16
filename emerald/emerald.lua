-- create global to make all components accessible globally
emerald = {}
emerald.logger = require('./emerald/logger')

emerald.__privateLoggerScope = emerald.logger:getLoggerScope('emerald')
emerald.__logger = emerald.__privateLoggerScope('main')

emerald.__logger.info('Initializing Emerald')