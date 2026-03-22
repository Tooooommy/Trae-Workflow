---
name: angular-patterns
description: Angular 模块设计、RxJS 响应式编程、依赖注入和性能优化最佳实践。适用于所有 Angular 项目。
---

# Angular 开发模式

用于构建企业级、可维护 Angular 应用的模式与最佳实践。

## 何时激活

- 编写新的 Angular 组件/服务
- 设计 Angular 模块架构
- 使用 RxJS 响应式编程
- 优化 Angular 应用性能

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Angular | 17+ | 18+ |
| RxJS | 7.8+ | 最新 |
| TypeScript | 5.2+ | 最新 |
| Angular CLI | 17+ | 最新 |
| NgRx | 17+ | 最新 (可选) |

## 核心原则

### 1. 模块化设计

```typescript
@NgModule({
  imports: [
    CommonModule,
    RouterModule.forChild(routes),
    SharedModule,
  ],
  declarations: [
    UserListComponent,
    UserDetailComponent,
    UserFormComponent,
  ],
  providers: [
    UserService,
  ],
})
export class UserModule {}
```

### 2. 单向数据流

```typescript
@Component({
  selector: 'app-user-list',
  template: `
    <app-user-card
      *ngFor="let user of users$ | async"
      [user]="user"
      (edit)="onEdit($event)"
      (delete)="onDelete($event)"
    />
  `,
})
export class UserListComponent {
  users$ = this.userService.users$;

  constructor(private userService: UserService) {}

  onEdit(user: User): void {
    this.userService.selectUser(user);
  }

  onDelete(user: User): void {
    this.userService.deleteUser(user.id);
  }
}
```

### 3. 响应式编程

```typescript
@Component({
  selector: 'app-search',
  template: `
    <input
      type="text"
      [formControl]="searchControl"
      placeholder="Search..."
    />
    <app-search-results [results]="results$ | async"></app-search-results>
  `,
})
export class SearchComponent implements OnInit, OnDestroy {
  searchControl = new FormControl('');
  results$!: Observable<SearchResult[]>;
  private destroy$ = new Subject<void>();

  ngOnInit(): void {
    this.results$ = this.searchControl.valueChanges.pipe(
      takeUntil(this.destroy$),
      debounceTime(300),
      distinctUntilChanged(),
      filter(query => query!.length >= 3),
      switchMap(query => this.searchService.search(query!)),
      catchError(() => of([]))
    );
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

## 依赖注入

### 服务提供者

```typescript
@Injectable({
  providedIn: 'root',
})
export class UserService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(`${this.apiUrl}/users`);
  }

  getUser(id: string): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/users/${id}`);
  }
}

// 模块级提供
@NgModule({
  providers: [
    UserService,
    { provide: API_URL, useValue: 'https://api.example.com' },
  ],
})
export class CoreModule {}

// 组件级提供
@Component({
  providers: [LocalService],
})
export class MyComponent {}
```

### 工厂提供者

```typescript
export function authServiceFactory(http: HttpClient, config: AppConfig) {
  return new AuthService(http, config.authUrl);
}

@NgModule({
  providers: [
    {
      provide: AuthService,
      useFactory: authServiceFactory,
      deps: [HttpClient, AppConfig],
    },
  ],
})
export class AuthModule {}
```

### InjectionToken

```typescript
export const API_CONFIG = new InjectionToken<ApiConfig>('api.config');

@NgModule({
  providers: [
    {
      provide: API_CONFIG,
      useValue: {
        baseUrl: 'https://api.example.com',
        timeout: 30000,
      },
    },
  ],
})
export class CoreModule {}

@Injectable()
export class ApiService {
  constructor(@Inject(API_CONFIG) private config: ApiConfig) {}
}
```

## RxJS 模式

### 状态管理

```typescript
@Injectable({ providedIn: 'root' })
export class UserStore {
  private state$ = new BehaviorSubject<UserState>({
    users: [],
    selectedUser: null,
    loading: false,
    error: null,
  });

  readonly users$ = this.state$.pipe(map(s => s.users));
  readonly selectedUser$ = this.state$.pipe(map(s => s.selectedUser));
  readonly loading$ = this.state$.pipe(map(s => s.loading));
  readonly error$ = this.state$.pipe(map(s => s.error));

  constructor(private userService: UserService) {}

  loadUsers(): void {
    this.updateState({ loading: true, error: null });

    this.userService.getUsers().subscribe({
      next: users => this.updateState({ users, loading: false }),
      error: error => this.updateState({ error, loading: false }),
    });
  }

  selectUser(user: User): void {
    this.updateState({ selectedUser: user });
  }

  private updateState(partial: Partial<UserState>): void {
    this.state$.next({ ...this.state$.value, ...partial });
  }
}
```

### 高阶操作符

```typescript
@Component({
  template: `
    <button (click)="refresh$.next()">Refresh</button>
    <app-user-list [users]="users$ | async"></app-user-list>
  `,
})
export class UserListComponent {
  private refresh$ = new Subject<void>();

  users$ = this.refresh$.pipe(
    startWith(void 0),
    switchMap(() => this.userService.getUsers().pipe(
      retry(3),
      catchError(() => of([]))
    ))
  );

  constructor(private userService: UserService) {}
}
```

### 组合流

```typescript
@Component({
  template: `
    <app-dashboard
      [stats]="stats$ | async"
      [chart]="chartData$ | async"
    ></app-dashboard>
  `,
})
export class DashboardComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();

  stats$!: Observable<Stats>;
  chartData$!: Observable<ChartData[]>;

  ngOnInit(): void {
    const userId$ = this.route.paramMap.pipe(
      map(params => params.get('userId')),
      filter(Boolean)
    );

    this.stats$ = userId$.pipe(
      takeUntil(this.destroy$),
      switchMap(id => this.statsService.getStats(id))
    );

    this.chartData$ = userId$.pipe(
      takeUntil(this.destroy$),
      switchMap(id => this.chartService.getData(id))
    );
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

## 组件模式

### 智能组件 vs 展示组件

```typescript
// 智能组件 (Container)
@Component({
  selector: 'app-user-container',
  template: `
    <app-user-list
      [users]="users$ | async"
      [loading]="loading$ | async"
      (select)="onSelect($event)"
    ></app-user-list>
  `,
})
export class UserContainerComponent {
  users$ = this.store.users$;
  loading$ = this.store.loading$;

  constructor(private store: UserStore) {}

  onSelect(user: User): void {
    this.store.selectUser(user);
    this.router.navigate(['/users', user.id]);
  }
}

// 展示组件 (Presentational)
@Component({
  selector: 'app-user-list',
  template: `
    <div *ngIf="loading">Loading...</div>
    <ul *ngIf="!loading">
      <li *ngFor="let user of users" (click)="select.emit(user)">
        {{ user.name }}
      </li>
    </ul>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserListComponent {
  @Input() users: User[] = [];
  @Input() loading = false;
  @Output() select = new EventEmitter<User>();
}
```

### 内容投影

```typescript
@Component({
  selector: 'app-card',
  template: `
    <div class="card">
      <div class="card-header">
        <ng-content select="[header]"></ng-content>
      </div>
      <div class="card-body">
        <ng-content></ng-content>
      </div>
      <div class="card-footer">
        <ng-content select="[footer]"></ng-content>
      </div>
    </div>
  `,
})
export class CardComponent {}

// 使用
<app-card>
  <div header>Title</div>
  <p>Content goes here</p>
  <div footer>
    <button>Action</button>
  </div>
</app-card>
```

### 动态组件

```typescript
@Component({
  selector: 'app-dynamic-container',
  template: `
    <ng-template #container></ng-template>
  `,
})
export class DynamicContainerComponent implements AfterViewInit {
  @ViewChild('container', { read: ViewContainerRef }) container!: ViewContainerRef;

  constructor(private componentFactoryResolver: ComponentFactoryResolver) {}

  ngAfterViewInit(): void {
    this.loadComponent(NotificationComponent);
  }

  loadComponent(component: Type<any>): void {
    this.container.clear();
    const factory = this.componentFactoryResolver.resolveComponentFactory(component);
    this.container.createComponent(factory);
  }
}
```

## 表单处理

### 响应式表单

```typescript
@Component({
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <div formGroupName="personal">
        <input formControlName="name" placeholder="Name">
        <app-error [control]="form.get('personal.name')"></app-error>
      </div>

      <div formArrayName="addresses">
        <div *ngFor="let address of addresses.controls; let i = index">
          <div [formGroupName]="i">
            <input formControlName="street">
            <input formControlName="city">
          </div>
          <button type="button" (click)="removeAddress(i)">Remove</button>
        </div>
      </div>

      <button type="submit" [disabled]="form.invalid">Submit</button>
    </form>
  `,
})
export class UserFormComponent implements OnInit {
  form!: FormGroup;

  get addresses(): FormArray {
    return this.form.get('addresses') as FormArray;
  }

  constructor(private fb: FormBuilder) {}

  ngOnInit(): void {
    this.form = this.fb.group({
      personal: this.fb.group({
        name: ['', [Validators.required, Validators.minLength(2)]],
        email: ['', [Validators.required, Validators.email]],
      }),
      addresses: this.fb.array([]),
    });
  }

  addAddress(): void {
    this.addresses.push(this.fb.group({
      street: ['', Validators.required],
      city: ['', Validators.required],
    }));
  }

  removeAddress(index: number): void {
    this.addresses.removeAt(index);
  }

  onSubmit(): void {
    if (this.form.valid) {
      this.submit.emit(this.form.value);
    }
  }
}
```

### 自定义验证器

```typescript
export function passwordMatchValidator(
  controlName: string,
  matchingControlName: string
): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const controlValue = control.get(controlName)?.value;
    const matchingValue = control.get(matchingControlName)?.value;

    return controlValue === matchingValue ? null : { passwordMismatch: true };
  };
}

// 使用
this.form = this.fb.group({
  password: ['', Validators.required],
  confirmPassword: ['', Validators.required],
}, { validators: passwordMatchValidator('password', 'confirmPassword') });
```

## 性能优化

### ChangeDetectionStrategy.OnPush

```typescript
@Component({
  selector: 'app-user-card',
  template: `
    <div class="user-card">
      <h3>{{ user.name }}</h3>
      <p>{{ user.email }}</p>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserCardComponent {
  @Input() user!: User;
}
```

### TrackBy 函数

```typescript
@Component({
  template: `
    <li *ngFor="let user of users; trackBy: trackByUserId">
      {{ user.name }}
    </li>
  `,
})
export class UserListComponent {
  @Input() users: User[] = [];

  trackByUserId(index: number, user: User): string {
    return user.id;
  }
}
```

### 纯管道

```typescript
@Pipe({
  name: 'filter',
  pure: true,
})
export class FilterPipe implements PipeTransform {
  transform<T>(items: T[], predicate: (item: T) => boolean): T[] {
    return items.filter(predicate);
  }
}
```

## 路由模式

### 路由守卫

```typescript
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean | UrlTree> {
    return this.authService.isAuthenticated$.pipe(
      map(isAuth => isAuth || this.router.createUrlTree(['/login'], {
        queryParams: { redirect: state.url },
      }))
    );
  }
}

@Injectable({ providedIn: 'root' })
export class DataResolver implements Resolve<User> {
  constructor(private userService: UserService) {}

  resolve(route: ActivatedRouteSnapshot): Observable<User> {
    return this.userService.getUser(route.paramMap.get('id')!);
  }
}

const routes: Routes = [
  {
    path: 'user/:id',
    component: UserDetailComponent,
    canActivate: [AuthGuard],
    resolve: { user: DataResolver },
  },
];
```

## 测试模式

### 组件测试

```typescript
describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;
  let mockUserService: jasmine.SpyObj<UserService>;

  beforeEach(async () => {
    mockUserService = jasmine.createSpyObj('UserService', ['getUsers']);

    await TestBed.configureTestingModule({
      declarations: [UserListComponent],
      providers: [
        { provide: UserService, useValue: mockUserService },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
  });

  it('should display users', fakeAsync(() => {
    const users = [{ id: '1', name: 'Alice' }];
    mockUserService.getUsers.and.returnValue(of(users));

    fixture.detectChanges();
    tick();

    const elements = fixture.debugElement.queryAll(By.css('li'));
    expect(elements.length).toBe(1);
    expect(elements[0].nativeElement.textContent).toContain('Alice');
  }));
});
```

### 服务测试

```typescript
describe('UserService', () => {
  let service: UserService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UserService],
    });

    service = TestBed.inject(UserService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  it('should fetch users', () => {
    const mockUsers = [{ id: '1', name: 'Alice' }];

    service.getUsers().subscribe(users => {
      expect(users).toEqual(mockUsers);
    });

    const req = httpMock.expectOne('/api/users');
    expect(req.request.method).toBe('GET');
    req.flush(mockUsers);
  });
});
```

## 快速参考

| 模式 | 用途 |
|------|------|
| OnPush | 减少变更检测 |
| Async Pipe | 自动订阅 |
| Resolver | 预加载数据 |
| Guards | 路由保护 |
| Pure Pipe | 纯函数缓存 |
| TrackBy | 列表优化 |

**记住**：Angular 的依赖注入和 RxJS 是其核心优势。充分利用 OnPush 策略和 async pipe 来优化性能。
