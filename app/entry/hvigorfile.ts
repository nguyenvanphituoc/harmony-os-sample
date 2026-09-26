// Script for compiling build behavior. It is built in the build plug-in and cannot be modified currently.
import * as path from 'path';
import { runEnforce } from '../build-src/enforce/index';

export { HapTasks } from '@ohos/hvigor-ohos-arkui-x-plugin';

// §5 Enforce (docs/ui-layer.md §5, A8): same rule table as ../hvigorfile.ts, scanning the same
// app/ root — a module build (`hvigorw assembleHap -p module=entry`) loads this file, not the
// app-level one, so the module hvigorfile needs its own call. Runs alongside HapTasks above —
// never instead of it.
runEnforce(path.resolve(__dirname, '..'));
