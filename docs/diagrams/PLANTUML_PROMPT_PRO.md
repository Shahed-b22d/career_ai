# برومبت احترافي لـ PlantUML — Career AI

انسخ المحتوى داخل صندوق **PROMPT** بالكامل إلى ChatGPT / Claude / PlantUML Online AI.

---

## PROMPT (English — recommended for best diagram quality)

```
You are a senior software architect and PlantUML expert. Generate TWO separate, publication-quality PlantUML diagrams for the "Career AI" graduation project.

## Project context
- Mobile app: Flutter (Dart) — career guidance for job seekers and companies
- Backend: Laravel 10 REST API + Laravel Sanctum authentication
- Database: MySQL / MariaDB (database name: career_ai)
- AI: Google Gemini Flash API via AiCareerService (server-side only)
- AI pipeline: CV Gap Analysis → Learning Roadmap → Quiz (70% pass) → ATS CV PDF

## Output requirements (STRICT)
1. Produce exactly TWO code blocks: CareerAI_ERD.puml and CareerAI_ClassDiagram.puml
2. Use !theme cerulean-outline, skinparam linetype ortho, skinparam roundcorner 8, dpi 150
3. Include a professional title, subtitle, and legend
4. Use color-coded stereotypes/packages:
   - Core entities: blue tint
   - AI-related tables/classes: amber/yellow tint
   - Business (jobs): green tint
   - Infrastructure: gray tint
5. Add notes for AI pipeline steps and API endpoints
6. Do NOT invent tables or classes not listed below
7. Use English labels for classes/tables; Arabic only in notes if needed
8. Ensure diagram fits A4 landscape when exported to PNG/SVG

---

## DIAGRAM 1: ERD (Entity Relationship Diagram)

Use PlantUML `entity` syntax with Crow's Foot notation.

### Tables and columns

**users** (PK: id)
id, name, email UK, email_verified_at, password, role ENUM(job,company),
phone, business_type, governorate, avatar_path, remember_token, timestamps

**job_seekers** (PK: id, FK: user_id → users CASCADE, UK user_id)
id, user_id, phone, timestamps

**companies** (PK: id, FK: user_id → users CASCADE, UK user_id)
id, user_id, phone, business_type, commercial_register_path, description, timestamps

**user_resumes** (PK: id, FK: user_id → users nullable)
id, user_id, target_job, original_text LONGTEXT, current_skills JSON, missing_skills JSON, timestamps

**user_roadmaps** (PK: id, FK: user_id nullable CASCADE)
id, user_id, target_job, roadmap_text, missing_skills JSON, suggested_courses JSON,
completed_skills JSON, is_active BOOLEAN, timestamps

**user_quizzes** (PK: id, FK: user_id nullable CASCADE)
id, user_id, tested_skills JSON, quiz_data JSON, score INT, timestamps

**jobs** (PK: id, FK: user_id → users CASCADE)
id, user_id, title, job_type, location, salary, description, requirements,
is_paid, payment_session_id, timestamps

**shortlists** (PK: id, FK: company_user_id → users CASCADE, UK company_user_id+candidate_email)
id, company_user_id, candidate_name, candidate_email, candidate_phone,
candidate_governorate, candidate_role, match_score, timestamps

**complaints** (PK: id, FK: user_id CASCADE)
id, user_id, role, subject, message, status, timestamps

**personal_access_tokens** (Sanctum, morph to users)

### Relationships
- users 1 — 0..1 job_seekers (role=job)
- users 1 — 0..1 companies (role=company)
- users 1 — 0..1 user_resumes
- users 1 — * user_roadmaps
- users 1 — * user_quizzes
- users 1 — * jobs
- users 1 — * complaints
- users 1 — * shortlists (as company)
- users 1 — * personal_access_tokens

### ERD notes to include
- user_resumes: POST /api/ai/cv/gap-analysis
- user_roadmaps: POST /api/ai/career/roadmap
- user_quizzes: quiz generate + submit, pass ≥70%

---

## DIAGRAM 2: UML Class Diagram (Layered Architecture)

Organize into packages:

### Package: Presentation Layer (Flutter)
- MyApp
- Screens: SplashScreen, AuthScreen, SignUpScreen, MainScreen, UserDashboard,
  CompanyDashboard, UploadCvScreen, CvAnalysisScreen, RoadmapScreen, QuizScreen,
  PostJobScreen, JobDetailsScreen, ComplaintScreen, AdminDashboardPro
- AiApiService (static methods: register, login, analyzeGap, generateRoadmap,
  generateQuiz, submitQuiz, generateAtsCv, getActiveJobs, _cleanAndDecode)
- LocalStorageService, NotificationService
- Widgets: CustomButton, CustomInputField, LoadingOverlay, AppTheme

### Package: Application Layer (Laravel)
- AuthController, AiController, JobController, ComplaintController
- AiController depends on AiCareerService

### Package: Domain Layer (Eloquent)
- User, JobSeeker, Company, UserResume, UserRoadmap, UserQuiz, Job, Shortlist, Complaint
- Show Eloquent relationships (hasOne, hasMany, belongsTo)

### Package: AI & Infrastructure
- AiCareerService: callGemini, readCv, analyzeGap, generateRoadmapAndCourses,
  generateQuiz, generateAtsCv
- External: Google Gemini API, PdfParser, DomPDF

### Package: External Systems
- Gemini API, Firebase Auth, MySQL

### Dependencies to draw
- Screens → AiApiService → Controllers (HTTP dashed arrows labeled /api/auth, /api/ai, /api/jobs)
- AiController → AiCareerService → Gemini
- AiController → UserResume, UserRoadmap, UserQuiz
- Include a note box: AI Pipeline (5 steps)

---

## Styling checklist
- [ ] Title block with project name
- [ ] Legend explaining PK, FK, UK, cardinalities
- [ ] Orthogonal lines
- [ ] Grouped packages with background colors
- [ ] Notes for AI endpoints
- [ ] No overlapping text
- [ ] @startuml / @enduml wrappers

Generate complete, renderable PlantUML code now. No explanations outside the code blocks.
```

---

## PROMPT (عربي — مختصر)

```
أنت مهندس برمجيات خبير في PlantUML. أنشئ مخططين احترافيين بجودة رسالة ماجستير/تخرج:

1) ERD لقاعدة career_ai (MySQL) — جداول: users, job_seekers, companies, user_resumes,
   user_roadmaps, user_quizzes, jobs, shortlists, complaints, personal_access_tokens
   مع PK/FK/UK والعلاقات وملاحظات مسار AI.

2) Class Diagram بطبقات: Flutter Presentation, Laravel Application, Eloquent Domain,
   AI Service, External (Gemini, Firebase, MySQL).

استخدم cerulean-outline theme، ألوان حسب النوع، legend، عنوان، ملاحظات API.
لا تخترع كيانات غير موجودة. كود PlantUML كامل قابل للتصدير PNG.
```

---

## ملفات جاهزة في المشروع

| ملف | الوصف |
|-----|--------|
| `docs/diagrams/CareerAI_ERD.puml` | ERD احترافي جاهز |
| `docs/diagrams/CareerAI_ClassDiagram.puml` | Class Diagram احترافي جاهز |

### التصدير

1. افتح https://www.plantuml.com/plantuml/uml/
2. الصق محتوى الملف
3. Export → PNG أو SVG (للرسالة)

أو في VS Code: إضافة **PlantUML** → Alt+D لمعاينة.
