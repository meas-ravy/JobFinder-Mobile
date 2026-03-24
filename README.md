# Jober

**Jober System** is a job-finding app that connects job seekers with recruiters. It helps people find jobs easily, helps companies hire the right employees faster.

📌 **Note:** This project was developed as a final-year academic project at the **Royal University of Phnom Penh (RUPP)**.

## Features

👤 1. Job Seeker Role

- View Job Posts: Browse and search for available job opportunities.
- Create CV: Build and manage your professional profile/resume.
- Apply for Jobs: Submit applications to companies easily.
- Notifications: Get instant alerts on your job application status.
- Real-time Chat: Message recruiters directly to discuss job details.

💼 2. Recruiter Role

- Post Jobs: Create and publish new job openings.
- Manage Applications: Accept or reject job seekers who applied.
- Chat with Seekers: Communicate with potential candidates in real-time.

### Project Structure (High Level)
```
JobFinder-Mobile/
    └── lib/
        ├── core/
        │   ├── constants/
        │   ├── enum/
        │   ├── helper/
        │   ├── networks/
        │   ├── routes/
        │   ├── services/
        │   ├── theme/
        │   ├── widgets/
        ├── features/
        │   ├── auth/
        │   │   ├── data/
        │   │   ├── domain/
        │   │   ├── presentation/
        │   ├── chat/
        │   ├── job_seeker/
        │   │   ├── data/
        │   │   ├── domain/
        │   │   ├── presentation/
        │   ├── notifications/
        │   │   ├── data/
        │   │   ├── domain/
        │   │   ├── presentation/
        │   ├── recruiter/
        │   │   ├── data/
        │   │   ├── domain/
        │   │   └── presentation/
        │   ├── buton_nav_recruiter.dart
        │   ├── main_wrapper.dart
        │   ├── onboarding_screen.dart
        │   ├── splash_screen.dart
        ├── l10n/
        ├── shared/
        │   ├── components/
        │   ├── provider/
        │   ├── screen/
        │   ├── utils/
        │   └── widget/
        ├── firebase_options.dart
        ├── main.dart
        ├── objectbox-model.json
        └── objectbox.g.dart
```
## 📱 App Screens

<h3 align="center">Splash & Onboarding Screen</h3>
<p align="center">
  <img src="assets/image/splash_screen.png" alt="Splash Screen"/>
</p>

<h3 align="center">Authentication & Role Selection Screen</h3>
<p align="center">
  <img src="assets/image/auth_screen.png" alt="Authentication Screen"/>
</p>

<h3 align="center">Job Seeker – Light & Dark Screens</h3>
<p align="center">
  <img src="assets/image/job_seeker_light.png" alt="Job Seeker Light"/>
  <img src="assets/image/job_seeker_dark.png" alt="Job Seeker Dark"/>
</p>

<h3 align="center">Recruiter – Light Screens</h3>
<p align="center">
  <img src="assets/image/recruiter_light.png" alt="Recruiter Screen"/>
</p>
