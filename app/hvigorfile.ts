// Script for compiling build behavior. It is built in the build plug-in and cannot be modified currently.
import { runEnforce } from './build-src/enforce/index';

export { AppTasksForArkUIX } from '@ohos/hvigor-ohos-arkui-x-plugin';

// §5 Enforce (docs/ui-layer.md §5, A8): the L1-L11 rule table runs on every hvigor invocation,
// alongside AppTasksForArkUIX above — never instead of it. A failing error-level rule throws
// here, before hvigor hands off to AppTasksForArkUIX's own tasks.
runEnforce(__dirname);
