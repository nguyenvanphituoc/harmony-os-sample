import { NavPort } from '../shared/kernel/NavPort';
import { TodoModule } from '../features/todo/TodoModule';
import { ListsPage } from '../features/todo/screens/lists/ListsPage';
import { ListPage } from '../features/todo/screens/list/ListPage';

class NavStackPort implements NavPort {
  private stack: NavPathStack;

  constructor(stack: NavPathStack) {
    this.stack = stack;
  }

  push(name: string, param: string): void {
    this.stack.pushPathByName(name, param);
  }

  pop(): void {
    this.stack.pop();
  }
}

@Entry
@ComponentV2
struct Index {
  private stack: NavPathStack = new NavPathStack();
  private todo: TodoModule = new TodoModule(new NavStackPort(this.stack));

  @Builder
  routes(name: string, param: Object) {
    if (name === 'List') {
      ListPage({ vm: this.todo.listViewModel(param as string) })
    }
  }

  build() {
    Navigation(this.stack) {
      ListsPage({ vm: this.todo.listsViewModel() })
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.routes)
  }
}
