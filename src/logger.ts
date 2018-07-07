'use strict';

import chalk from "chalk";
const isDebug = process.env.ores_is_debug === 'yes';

export const log = {
  info: console.log.bind(console, chalk.gray('[ores info]')),
  warning: console.error.bind(console, chalk.bold.yellow.bold('[ores warn]')),
  warn: console.error.bind(console, chalk.bold.magenta.bold('[ores warn]')),
  error: console.error.bind(console, chalk.redBright.bold('[ores error]')),
  debug: function (...args: any[]) {
    isDebug && console.log('[ores]', ...arguments);
  }
};

export default log;
