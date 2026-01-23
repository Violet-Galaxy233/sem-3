# SOFTWARE DESIGN DOCUMENT

**Version:** 1.0
**Date:** 16.01.2026

## SamaRasa Project
### AI-Powered Companion and Health Management System

---

**Prepared By:** Found 404 Team (Group 4)

| Name | Student ID |
|------|------------|
| ZHAO YUNUO | 227225 |
| FAN HAOQI | 227259 |
| HUA JIE | 226758 |
| WANG KAILUN | 227046 |
| YUE CHENGHAO | 227154 |
| ZHANG YAOYUAN | 226557 |

---

## Preface

This document contains the system design information for the SamaRasa project. The document is prepared according to the "IEEE Standard for Information Technology – Systems Design – Software Design Descriptions – IEEE Std 1016 – 1998".

This Software Design Documentation provides a complete description of all the system design and views of the SamaRasa Project.

The first section of this document includes purpose, scope, overview, reference material, definitions, and abbreviations of the project.

The second chapter of this document includes an overview of the functionality of the application. It describes the informal design generally.

The third chapter of this document will give the user a detailed description of each function of the system.

The fourth chapter of this document contains data design and data description of the project.

The fifth chapter of this document contains a general overview of what the user interface will look like.

The sixth and last chapter of this document includes the requirements matrix of the project.

---

## Change of History

| Version Number | DATE | Number of figure | A*,M*,D* | Title of Brief Description |
|----------------|------|------------------|----------|---------------------------|
| 1.0 | 16.01.2026 | | | Original |

**A*:** Added
**M*:** Modified
**D*:** Deleted

---

## Table of Contents

1. [Introduction](#1-introduction)
   - 1.1 Scope
   - 1.2 Purpose
   - 1.3 Overview
   - 1.4 Reference Material
   - 1.5 Definitions and Abbreviations
2. [Conceptual Model for Software Design Descriptions](#2-conceptual-model-for-software-design-descriptions)
   - 2.1 Software Design in Context
   - 2.2 Software Design Descriptions within the Life Cycle
3. [Design Description Information Content](#3-design-description-information-content)
   - 3.1 SDD Identification
   - 3.2 Design Stakeholders and Their Concerns
   - 3.3 Design Views
   - 3.4 Design Viewpoints
   - 3.5 Design Rationale
   - 3.6 Design Languages
4. [Design Viewpoints](#4-design-viewpoints)
   - 4.1 Logical Viewpoint
   - 4.2 Information Viewpoint
   - 4.3 Interface Viewpoint
   - 4.4 Interaction Viewpoint
   - 4.5 Context Viewpoints
   - 4.6 Composition Viewpoints
5. [Requirements Matrix](#5-requirements-matrix)

---

## Table of Figures

- Figure 1 – Class Diagram of SamaRasa
- Figure 2 – ER Diagram
- Figure 3 – System Architecture Diagram
- Figure 4 – Deployment Diagram
- Figure 5 – Elderly View Home Screen (English)
- Figure 6 – Elderly View Home Screen (Malay)
- Figure 7 – Chat with Me Screen
- Figure 8 – My Medications Screen
- Figure 9 – Medication Reminder Screen
- Figure 10 – Health Diary Screen
- Figure 11 – Emergency Help Screen
- Figure 12 – Caregiver Login Screen
- Figure 13 – Caregiver Dashboard - Medication Schedule
- Figure 14 – Caregiver Dashboard - Health Analytics
- Figure 15 – Caregiver Dashboard - Alerts & Logs
- Figure 16 – Sequence Diagram of AI Chat Component
- Figure 17 – Sequence Diagram of Medication Reminder Component
- Figure 18 – Sequence Diagram of Caregiver Add Medication Component
- Figure 19 – Sequence Diagram of SOS Component
- Figure 20 – Sequence Diagram of Caregiver Dashboard Component
- Figure 21 – Sequence Diagram of Mood Recording Component
- Figure 22 – Sequence Diagram of Data Synchronization
- Figure 23 – Use Case Diagram of Elderly User
- Figure 24 – Use Case Diagram of Caregiver
- Figure 25 – Component Diagram

---

## 1. Introduction

### 1.1 Scope

This document provides comprehensive system design information for programmers to develop the SamaRasa application. The document includes all necessary details for code development, including class structures, database schemas, user interfaces, and component interactions.

### 1.2 Purpose

This document describes the conceptual design of the SamaRasa Project according to the document guidelines presented in the IEEE 1016-1998 Recommended Practice for Software Design Descriptions (SDD).

The SDD shows how the software system will be structured to satisfy the requirements identified in the Software Requirements Specification (SRS). It is a translation of requirements into a description of the software structure, software components, interfaces, and data necessary for the implementation phase. In essence, the SDD becomes a detailed blueprint for the implementation activity. In a complete SDD, each requirement must be traceable to one or more design entities.

### 1.3 Overview

The purpose of this document is to help the reader visualize the solution to the project presented. This document verifies how the design meets the requirements stipulated in the SRS document through design viewpoints. The design viewpoints will cover all design elements presented before.

By using information from IEEE 1016-1998, this document will provide a direct approach to the development of this project hence reducing feature creep and pointedly determine the quality of the design.

SamaRasa is designed to address Malaysia's aging population challenges by providing:
- Voice-first bilingual interaction (Bahasa Malaysia/English)
- AI-powered emotional companionship
- Smart medication management
- Emergency SOS alerts
- Caregiver monitoring dashboard

### 1.4 Reference Material

1. IEEE, *IEEE Std 1016-1998 Recommended Practice for Software Design Descriptions*, 1998-09-23, The Institute of Electrical and Electronics Engineers, Inc.
2. SSW3001 Group Project Guidelines, Semester 1 2025/2026, Universiti Putra Malaysia
3. Ministry of Health Malaysia, *National Policy for Older Persons (Revised 2024)*
4. SamaRasa Software Requirements Specification (SRS) Document, Version 1.0

### 1.5 Definitions and Abbreviations

| Term | Definition |
|------|------------|
| Database | Collection of all the information monitored by this system |
| Elderly User | Primary user of the SamaRasa application, aged 65+ |
| Caregiver | Family member or nurse responsible for monitoring the elderly user |
| AI | Artificial Intelligence |
| STT | Speech-to-Text - Technology that converts spoken words to text |
| TTS | Text-to-Speech - Technology that converts text to spoken words |
| SOS | Emergency alert system |
| IEEE | The Institute of Electrical and Electronics Engineers |
| SRS | Software Requirements Specification |
| SDD | Software Design Description |
| JSON | JavaScript Object Notation - A lightweight data-interchange format |
| HTTPS | Hypertext Transfer Protocol Secure |
| API | Application Programming Interface |
| REST/RESTful | Representational State Transfer - An architectural style for APIs |
| SQLite | A lightweight relational database management system |
| Firebase | Google's mobile and web application development platform |
| WCAG | Web Content Accessibility Guidelines |
| PDPA | Personal Data Protection Act (Malaysia) |
| UUID | Universally Unique Identifier |

---

## 2. Conceptual Model for Software Design Descriptions

Information about concepts and context of SDD and stakeholders will be given in this part.

### 2.1 Software Design in Context

#### 2.1.1 Technologies Used

The system is developed using the following technologies:

| Layer | Technology |
|-------|------------|
| Frontend (Elderly App) | HTML5, CSS3, JavaScript, React/Vue.js |
| Frontend (Caregiver Dashboard) | React.js, Responsive Web Design |
| Backend Server | Node.js / Python (Flask/FastAPI) |
| Database | SQLite (local) / Firebase Firestore (cloud sync) |
| Voice Processing | Web Speech API (Browser native STT/TTS) |
| Communication | HTTPS, JSON, RESTful APIs |
| Prototyping | Figma |

#### 2.1.2 Application Overview

The main goal of the SamaRasa project is to empower elderly Malaysians to live independently while maintaining connection with their caregivers. The final product will be a tablet-optimized web application for elderly users and a responsive web dashboard for caregivers.

**Key Features:**
1. **AI Chat Companion**: A conversational agent that greets users, provides emotional support, and detects mood through sentiment analysis
2. **Smart Medication Reminder**: Voice-based alerts with visual confirmation for medication adherence
3. **Health Diary**: Tracks daily mood and well-being
4. **Emergency SOS Alert**: One-touch emergency notification system
5. **Caregiver Dashboard**: Remote monitoring and medication schedule management

The application supports bilingual interaction in English and Bahasa Malaysia, with a voice-first interface designed for users with limited digital literacy.

### 2.2 Software Design Descriptions within the Life Cycle

#### 2.2.1 Influences on SDD Preparation

The Software Requirements Specification (SRS) is the main source for SDD preparation. The functional and non-functional requirements are the main factors determining the design of the project. Key influences include:
- Accessibility requirements for elderly users (WCAG 2.1 compliance)
- Bilingual support requirements
- Real-time synchronization between devices
- Security and privacy requirements (PDPA compliance)

#### 2.2.2 Influences on Software Life Cycle Products

During the implementation and preparation of the SDD, some requirements may change due to unexpected constraints. The testing phase of the project can be prepared using the information in this System Design Document.

#### 2.2.3 Design Verification and Design Role in Validation

Verification determines whether a software work product fulfills specified requirements. Validation determines that the requirements for a specific intended use of a software work product are fulfilled. Therefore, verification and validation results are controlled by the requirements defined in the SRS.

---

## 3. Design Description Information Content

### 3.1 SDD Identification

SamaRasa is designed for Malaysian elderly users aged 65 and above who may have:
- Limited digital literacy
- Visual impairments (presbyopia)
- Motor limitations (hand tremors)
- Cognitive decline (short-term memory issues)

The system will be deployed as a web-based application optimized for tablet devices, with a separate caregiver portal accessible via any modern web browser.

### 3.2 Design Stakeholders and Their Concerns

| Stakeholder | Primary Concerns |
|-------------|------------------|
| Elderly Users | Simplicity, accessibility, reliability, voice interaction |
| Caregivers | Real-time monitoring, easy configuration, alert notifications |
| Development Team | Maintainability, scalability, code quality |
| Healthcare Providers | Data accuracy, compliance with health guidelines |

### 3.3 Design Views

Unified Modeling Language (UML) 2.0 is used for graphical representations of viewpoints in the SamaRasa Project. The following diagram types are provided:
- Class Diagrams
- Entity-Relationship Diagrams
- Sequence Diagrams
- Use Case Diagrams
- Component Diagrams
- Deployment Diagrams

### 3.4 Design Viewpoints

The following design viewpoints are covered in this document:
- **Logical Viewpoint**: Class structure and relationships
- **Information Viewpoint**: Data entities and database schema
- **Interface Viewpoint**: User interface designs
- **Interaction Viewpoint**: Sequence diagrams showing component interactions
- **Context Viewpoint**: Use case diagrams
- **Composition Viewpoint**: Component architecture

### 3.5 Design Rationale

The design focuses on:
1. **Accessibility**: Large fonts (min 24px), high contrast (7:1 ratio), large touch targets
2. **Simplicity**: Maximum 2-layer navigation, grid-based layouts
3. **Reliability**: Offline capability with automatic sync, 99.9% medication alarm success rate
4. **Security**: HTTPS encryption, PIN-protected settings, PDPA compliance

### 3.6 Design Languages

- UML 2.0 for all structural and behavioral diagrams
- Figma for user interface prototypes
- JSON for API data formats

---

## 4. Design Viewpoints

### 4.1 Logical Viewpoint

This viewpoint aims to show the key abstractions such as classes and interactions among them.

#### 4.1.1 Design Concerns

The Logical viewpoint is used to address the development and reuse of adequate abstractions and their implementations.

#### 4.1.2 Design Elements - Class Diagram

**Figure 1 – Class Diagram of SamaRasa**

*(Reference: alldiagram.pdf Page 1)*

The class diagram shows the following main classes and their relationships:

---

**User (Abstract Class)**

| Attribute | Type | Description |
|-----------|------|-------------|
| userID | UUID | Unique identifier for the user |
| preferredLang | String | Language preference ('en' or 'ms') |

| Method | Description |
|--------|-------------|
| +login() | Authenticates the user |

---

**Elderly (extends User)**

| Attribute | Type | Description |
|-----------|------|-------------|
| currentLocation | GPS | Current GPS coordinates |
| moodScore | Integer | Current mood score (0-10) |

| Method | Description |
|--------|-------------|
| +interactWithAI() | Initiates conversation with AI companion |
| +confirmMedication(status: Enum) | Confirms medication taken/skipped |
| +triggerSOS() | Triggers emergency alert |
| +completeRiskAssessment() | Completes fall risk questionnaire |

---

**Caregiver (extends User)**

| Attribute | Type | Description |
|-----------|------|-------------|
| phoneNumber | String | Contact phone number |
| email | String | Email address |

| Method | Description |
|--------|-------------|
| +manageMedicationSchedule() | Add/edit/delete medication schedules |
| +viewHealthDashboard() | View health analytics and logs |
| +receiveEmergencyAlert() | Receive SOS notifications |

---

**CaregiverDashboard**

| Attribute | Type | Description |
|-----------|------|-------------|
| calendarView | Calendar | Medication adherence calendar |
| medicationAdherenceData | Map<Date, Enum> | Daily adherence status |
| moodTrendGraph | Graph | Mood trend visualization |

| Method | Description |
|--------|-------------|
| +displayCalendar() | Shows medication calendar |
| +updateMedicationSchedule(medID, newTime) | Updates schedule remotely |
| +visualizeMoodTrend() | Displays mood trend graph |
| +showAdherenceSummary() | Shows adherence statistics |

---

**ChatSession**

| Attribute | Type | Description |
|-----------|------|-------------|
| sessionID | UUID | Unique session identifier |
| conversationHistory | List<String> | History of conversation |
| detectedSentiment | String | Detected mood from conversation |

| Method | Description |
|--------|-------------|
| +initiateGreeting() | Starts conversation with greeting |
| +processAudioInput() | Processes voice input via STT |
| +generateResponse() | Generates AI response |

---

**Medication**

| Attribute | Type | Description |
|-----------|------|-------------|
| medID | UUID | Unique medication identifier |
| name | String | Name of medication |
| dosage | String | Dosage information |
| scheduledTime | Time | Scheduled reminder time |
| pillPhoto | Image | Photo of the pill |
| currentStatus | Enum | PENDING/TAKEN/SKIPPED/MISSED |

| Method | Description |
|--------|-------------|
| +triggerReminderAlert() | Triggers medication reminder |
| +playAudioAnnouncement() | Plays voice reminder |

---

**MedicationLog**

| Attribute | Type | Description |
|-----------|------|-------------|
| logID | UUID | Unique log identifier |
| timestamp | DateTime | Time of action |
| statusAction | Enum | TAKEN/SKIPPED/MISSED |

| Method | Description |
|--------|-------------|
| +logEvent() | Records medication event |

---

**EmergencyAlert**

| Attribute | Type | Description |
|-----------|------|-------------|
| alertID | UUID | Unique alert identifier |
| timestamp | DateTime | Time alert was triggered |
| gpsLocation | String | GPS coordinates |

| Method | Description |
|--------|-------------|
| +initiateCountdown() | Starts 5-second countdown |
| +sendToCaregiver() | Sends alert to caregiver |

---

**FallRiskAssessment**

| Attribute | Type | Description |
|-----------|------|-------------|
| questionnaireData | List<Boolean> | Responses to questions |
| calculatedRiskScore | Integer | Risk score (0-10) |

| Method | Description |
|--------|-------------|
| +presentQuestionnaire() | Displays questions |
| +calculateScore() | Calculates risk score |
| +displayRecommendation() | Shows recommendations |

---

**Class Relationships:**

1. **User** is the parent class of **Elderly** and **Caregiver** (Inheritance)
2. **Elderly** has 1 **Caregiver** who monitors them (1:1..* Association)
3. **Elderly** participates in 0..* **ChatSession** (Association)
4. **Elderly** has schedule of 0..* **Medication** (Composition)
5. **Medication** generates 0..* **MedicationLog** (Association)
6. **Elderly** triggers 0..* **EmergencyAlert** (Association)
7. **Elderly** completes 0..* **FallRiskAssessment** (Association)
8. **Caregiver** accesses 1 **CaregiverDashboard** (Association)

---

### 4.2 Information Viewpoint

**Figure 2 – ER Diagram**

*(Reference: alldiagram.pdf Page 1)*

#### 4.2.1 Design Concern

This viewpoint aims to show the way that the system stores, manages, and manipulates the persistent information that the system will maintain.

#### 4.2.2 Design Elements - Database Schema

**Table: Caregiver**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| CaregiverID | UUID | PK | Primary key |
| Email | String | Unique | Login email |
| PasswordHash | String | | Encrypted password |
| Phone | String | | Contact number |

---

**Table: ElderlyUser**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| UserID | UUID | PK | Primary key |
| CaregiverID | UUID | FK | Foreign key to Caregiver |
| Name | String | | User's name |
| PreferredLang | String | | 'en' or 'ms' |
| PinCode | String | Encrypted | Settings protection PIN |

---

**Table: MedicationSchedule**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| ScheduleID | UUID | PK | Primary key |
| UserID | UUID | FK | Foreign key to ElderlyUser |
| MedName | String | | Medication name |
| Dosage | String | | Dosage amount |
| ScheduledTime | Time | | Reminder time |
| PillPhotoURL | String | | URL to pill image |
| IsActive | Boolean | | Active status |

---

**Table: MedicationLog**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| LogID | UUID | PK | Primary key |
| ScheduleID | UUID | FK | Foreign key to MedicationSchedule |
| ScheduledDate | Date | | Date of scheduled dose |
| Status | Enum | | TAKEN/MISSED/SKIPPED |
| ActionTimestamp | DateTime | | Time of user action |

---

**Table: MoodLog**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| MoodID | UUID | PK | Primary key |
| UserID | UUID | FK | Foreign key to ElderlyUser |
| MoodScore | Integer | | Score 0-10 |
| DetectedKeywords | String | | Keywords from chat |
| Timestamp | DateTime | | Time recorded |

---

**Table: SOSAlert**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| AlertID | UUID | PK | Primary key |
| UserID | UUID | FK | Foreign key to ElderlyUser |
| GPSLocation | String | | Coordinates |
| TriggeredTime | DateTime | | Time triggered |
| IsResolved | Boolean | | Resolution status |

---

**Table: RiskAssessment**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| AssessmentID | UUID | PK | Primary key |
| UserID | UUID | FK | Foreign key to ElderlyUser |
| RiskScore | Integer | | Calculated score |
| DateTaken | Date | | Assessment date |
| ResponsesJSON | Text | | JSON of responses |

---

**Database Relationships:**

- Caregiver **manages** ElderlyUser (1:N)
- ElderlyUser **has schedule** MedicationSchedule (1:N)
- MedicationSchedule **generates logs** MedicationLog (1:N)
- ElderlyUser **records mood** MoodLog (1:N)
- ElderlyUser **triggers** SOSAlert (1:N)
- ElderlyUser **completes** RiskAssessment (1:N)

---

### 4.3 Interface Viewpoint

This section describes the interface and components of the SamaRasa application.

#### 4.3.1 Design Concern

Concerns of the stakeholders in this document are **accessibility**, **simplicity**, and **reliability**. The UI must comply with WCAG 2.1 AAA standards.

#### 4.3.2 Design Elements - User Interface

**UI Design Standards:**

| Element | Specification |
|---------|---------------|
| Font Family | San Francisco / Roboto (Sans-serif) |
| Min Body Font Size | 24px |
| Header Font Size | 36px |
| Contrast Ratio | > 7:1 (WCAG AAA) |
| Touch Target Size | Minimum 48x48px |
| Color Coding | Green = Confirm, Red = Emergency/Stop, Blue = Information |

---

##### 4.3.2.1 Elderly View - Home Screen (English)

**Figure 5 – Elderly View Home Screen (English)**

*(Reference: alldiagram.pdf Page 4)*

The home screen displays:
- **Greeting Message**: "Good Morning" (time-based)
- **User Name**: "Puan Siti"
- **Four Main Feature Cards** (2x2 grid):
  1. **Chat with Me** - Opens AI companion chat
  2. **My Medications** - Shows medication schedule
  3. **Health Diary** - Opens mood logging
  4. **Safety Check** - Opens fall risk assessment
- **SOS Button**: Fixed red button at bottom-right
- **Disclaimer**: "This is a software aid, not a medical device"

---

##### 4.3.2.2 Elderly View - Home Screen (Malay)

**Figure 6 – Elderly View Home Screen (Malay)**

*(Reference: alldiagram.pdf Page 3)*

Same layout with Malay translations:
- "Selamat Pagi" (Good Morning)
- "Sembang dengan Saya" (Chat with Me)
- "Ubat Saya" (My Medications)
- "Diari Kesihatan" (Health Diary)
- "Pemeriksaan Keselamatan" (Safety Check)

Language toggle buttons at top: [English] [Melayu]

---

##### 4.3.2.3 Chat with Me Screen

**Figure 7 – Chat with Me Screen**

*(Reference: alldiagram.pdf Page 5)*

Interface elements:
- **Back Button**: "← Back" at top-left
- **Title**: "Chat with Me"
- **AI Message Bubble**: "How are you feeling today?"
- **Voice Input Button**: Large blue circular button with microphone icon
- **Label**: "Tap to Speak"
- **Visual Cue**: Pulsing waveform animation when listening

---

##### 4.3.2.4 My Medications Screen

**Figure 8 – My Medications Screen**

*(Reference: alldiagram.pdf Page 6)*

Displays list of medications as cards:

**Medication Card 1:**
- Pill Icon (blue)
- **Name**: "Amlodipine"
- **Dosage**: 5mg
- **Time**: 08:00
- **Days**: Mon, Tue, Wed (highlighted tags)
- **Instructions**: "Take with water after breakfast"

**Medication Card 2:**
- **Name**: "Metformin"
- **Dosage**: 500mg
- **Time**: 20:00
- **Days**: Mon, Tue, Wed
- **Instructions**: "Take with dinner"

---

##### 4.3.2.5 Medication Reminder Alert Screen

**Figure 9 – Medication Reminder Screen**

*(Reference: alldiagram.pdf Page 7)*

Full-screen modal alert:
- **Icon**: Large pill icon (green background)
- **Title**: "Medication Reminder"
- **Subtitle**: "Time to take your medicine"
- **Card**:
  - Medication Name: "Amlodipine"
  - Dosage: 5mg | Time: 08:00
  - Instruction: "Take with water after breakfast"
- **Action Buttons**:
  - [✓ Taken] - Large green button
  - [✗ Skip] - Gray button
- **Timer**: "Alert active for: 0m 50s"

---

##### 4.3.2.6 Health Diary Screen

**Figure 10 – Health Diary Screen**

*(Reference: alldiagram.pdf Page 8)*

- **Title**: "Health Diary"
- **Card**: "Today's Mood - How are you feeling?"
- **Mood Options** (2x2 + 1 grid):
  - 😊 Happy (green)
  - 😐 Okay (blue)
  - 😢 Sad (yellow)
  - 😰 Anxious (orange)
  - 👤👤 Lonely (purple)

---

##### 4.3.2.7 Emergency Help Screen

**Figure 11 – Emergency Help Screen**

*(Reference: alldiagram.pdf Page 9)*

After SOS activation:
- **Icon**: Large green checkmark
- **Title**: "Emergency Alert Sent!" (red text)
- **Message**: "Emergency services and your caregivers have been notified. Help is on the way."
- **Timer**: "Alert active for: 0:20"

---

##### 4.3.2.8 Caregiver Login Screen

**Figure 12 – Caregiver Login Screen**

*(Reference: alldiagram.pdf Page 10)*

- **Logo**: Heart icon with "SamaRasa"
- **Subtitle**: "Caregiver Dashboard"
- **Form Fields**:
  - Email: caregiver@example.com
  - Password: ••••••••
- **Login Button**: [→] Login
- **Helper Text**: "Demo login: Use any email and password"

---

##### 4.3.2.9 Caregiver Dashboard - Medication Schedule

**Figure 13 – Caregiver Dashboard - Medication Schedule**

*(Reference: alldiagram.pdf Page 11)*

Header:
- "SamaRasa Dashboard" | [→ Logout]
- User email display
- Tab Navigation: [Medication Schedule] [Health Analytics] [Alerts & Logs]

Content:
- **Title**: "Medication Schedule"
- **Subtitle**: "Manage daily medication reminders for your loved one"
- **[+ Add Medication]** button
- **Medication Cards** with Edit/Delete icons:
  - Amlodipine 5mg - Daily at 08:00 - Mon-Sun - "Take with water after breakfast"
  - Metformin 500mg - Daily at 20:00 - Mon-Sun - "Take with dinner"

---

##### 4.3.2.10 Caregiver Dashboard - Health Analytics

**Figure 14 – Caregiver Dashboard - Health Analytics**

*(Reference: alldiagram.pdf Page 12)*

- **Chart 1**: "Daily tracking of medication intake"
  - Bar chart showing Missed (red), Skipped (yellow), Taken (green)
  - X-axis: Dates (12/20 - 1/16)

- **Chart 2**: "Mood Trend (Last 14 Days)"
  - Line graph showing emotional well-being
  - Y-axis: Mood Score (0-10)

---

##### 4.3.2.11 Caregiver Dashboard - Alerts & Logs

**Figure 15 – Caregiver Dashboard - Alerts & Logs**

*(Reference: alldiagram.pdf Page 13)*

- **Section 1**: "SOS Alerts - Emergency notifications"
  - Alert Card: "Active SOS Alert" [Active badge]
  - Time: Jan 16, 08:39 AM
  - Location: 3.1390, 101.6869
  - [Mark as Resolved] button

- **Section 2**: "Medication Logs - Recent medication activity"
  - Log Entry: "Amlodipine - Scheduled: 08:00 - Jan 16, 08:01 AM" [Taken badge]

---

##### 4.3.2.12 System Architecture Diagram

**Figure 3 – System Architecture Diagram**

*(Reference: alldiagram.pdf Page 2)*

The deployment architecture shows:

**Client Layer (Frontend):**
- Elderly's tablet device running SamaRasa Companion Web App
- Uses Browser Web Speech API (STT/TTS)
- Local Storage for offline cache

**Simulated Server Layer:**
- API Gateway / Controller (Node.js)
- Core Logic Modules:
  - Analytics Module (Adherence & Mood Reports)
  - Safety & SOS Module (Emergency Handling)
  - Smart Medication Module (Scheduler & Alerts)
  - AI Chat Companion Module (Rule-based / Mock NLP)
- Data Layer: SQLite Database

**Caregiver Device:**
- Web Browser accessing Caregiver Dashboard
- HTTPS/JSON communication with backend

**Communication:**
- HTTPS / JSON (Secure Data) between all components
- Missed Dose Notifications and SOS Alerts via SMS/Email simulation

---

##### 4.3.2.13 Deployment Diagram

**Figure 4 – Deployment Diagram**

*(Reference: alldiagram.pdf Page 14)*

```
┌─────────────────────────────────────┐  ┌──────────────────────────────┐
│  «Tablet/Smartphone»                │  │  «Smartphone»                │
│  Client Device (Elderly User)       │  │  Client Device (Caregiver)   │
│  ┌─────────────────────────────┐    │  │  ┌────────────────────────┐  │
│  │ Web Browser (Chrome/Safari) │    │  │  │ Web Browser            │  │
│  │ ┌─────────────────────────┐ │    │  │  │ ┌──────────────────┐   │  │
│  │ │ SamaRasa Companion App  │ │    │  │  │ │ Caregiver        │   │  │
│  │ └─────────────────────────┘ │    │  │  │ │ Dashboard        │   │  │
│  └─────────────────────────────┘    │  │  │ └──────────────────┘   │  │
│              │                       │  │  └────────────────────────┘  │
│              ▼                       │  └──────────────────────────────┘
│  ┌─────────────────────────────┐    │               │
│  │ «Browser Native»            │    │               │
│  │ Web Speech API (STT/TTS)    │    │               │
│  └─────────────────────────────┘    │               │
│              │                       │               │
│  ┌─────────────────────────────┐    │               │
│  │ Local Storage (Offline)     │    │               │
│  └─────────────────────────────┘    │               │
└─────────────────────────────────────┘               │
               │                                       │
               │ HTTPS (JSON)                          │ HTTPS (JSON)
               ▼                                       ▼
       ┌───────────────────────────────────────────────────┐
       │        «Python/Node.js»                           │
       │        Backend Server (Simulated)                 │
       │  ┌──────────────────────────────────────────┐     │
       │  │ API Controller                            │     │
       │  └──────────────────────────────────────────┘     │
       │       │              │                │            │
       │       ▼              ▼                ▼            │
       │  ┌─────────┐  ┌─────────────┐  ┌──────────────┐   │
       │  │ AI      │  │ Medication  │  │ SQLite /     │   │
       │  │ Response│  │ Scheduler   │  │ Firestore    │   │
       │  │ Logic   │  │             │  │              │   │
       │  └─────────┘  └─────────────┘  └──────────────┘   │
       └───────────────────────────────────────────────────┘
```

---

### 4.4 Interaction Viewpoint

This section presents sequence diagrams showing how components interact during key use cases.

#### 4.4.1 AI Chat Companion Component

**Figure 16 – Sequence Diagram of AI Chat Component**

*(Reference: alldiagram.pdf Page 14)*

**Scenario**: Daily Greeting & Mood Capture (REQ-CHAT-01)

**Actors/Objects**: Elderly User → Client UI (Tablet) → Web Speech API (Browser) → Backend Server (Node/Python) → Database (SQLite/Firebase)

**Flow**:
1. System triggers greeting based on time ("Good Morning")
2. Client UI requests TTS (Text-to-Speech)
3. Audio plays: "Good morning! How are you feeling today?"
4. User speaks (e.g., "I feel a bit sad and dizzy")
5. Client shows "Listening" animation (pulsing waveform)
6. Audio stream sent to Web Speech API
7. Transcribed text returned: "I feel a bit sad and dizzy"
8. Client displays "Thinking..." / "Sedang fikir..."
9. POST /api/conversation (text, userID) to backend
10. Backend parses keywords (Sentiment Analysis - REQ-CHAT-03):
    - Detected: "Sad" (Mood), "Dizzy" (Health Symptom)
11. INSERT INTO DailyLogs (MoodScore, Keywords, Time)
12. Database acknowledges save
13. Backend generates empathetic response
14. Return JSON: {response: "I understand. Please rest...", tone: "soft"}
15. Client requests TTS for response
16. Audio output plays (empathetic voice)
17. Visual + Audio response shown to user

**Post-condition**: Updates Mood Trend for Caregiver Dashboard

---

#### 4.4.2 Medication Reminder Component

**Figure 17 – Sequence Diagram of Medication Reminder Component**

*(Reference: alldiagram.pdf Page 15)*

**Actors/Objects**: System Timer → Client UI (Tablet) → Backend System → Database → Caregiver (Mobile)

**Flow**:
1. Alarm triggered at 08:00 AM
2. Full-screen modal displayed (REQ-MED-01)
3. System starts countdown (15 minutes)
4. Audio announcement plays every 30 seconds (REQ-MED-03)
5. **If user responds**:
   - User clicks [Taken] or [Skip]
   - Status updated in database (REQ-MED-05)
   - Alarm dismissed
6. **If no user interaction (timeout reached)**:
   - Backend reports timeout
   - Query current status: "PENDING"
   - Update status to "MISSED"
   - Generate alert payload (User ID, Med Name, Time)
   - Send SMS/Email notification to caregiver (REQ-MED-04)
   - Caregiver receives: "Alert: Dad missed 8AM Amlodipine"
7. Client minimizes alarm / Shows "Missed" notification

---

#### 4.4.3 Caregiver Add Medication Component

**Figure 18 – Sequence Diagram of Caregiver Add Medication Component**

*(Reference: alldiagram.pdf Page 15)*

**Pre-condition**: Caregiver logged in via Email/Password (REQ-SEC-01)

**Actors/Objects**: Caregiver → Caregiver Web Portal → Backend Server → Database → Elderly Client (Tablet)

**Flow**:
1. Caregiver selects "Medication Management"
2. Portal displays current schedule (REQ-DASH-01)
3. Caregiver clicks [+ Add Medication] / [Edit]
4. Input details (Name, Dosage, Time)
5. Example input: Name="Amlodipine", Dosage="5mg", Time="08:00"
6. Caregiver clicks [Save]
7. HTTPS POST /api/medication (JSON Payload)
8. Data encrypted in transit
9. Backend validates data format
10. INSERT or UPDATE Medication Record
11. Return Success (ID: 101)
12. HTTP 200 OK (Success Message)
13. Portal displays "Schedule Updated Successfully"
14. **Real-time Sync** (REQ-MED-01 Pre-condition):
    - Backend pushes notification: "New Schedule Available"
    - Elderly device GET /api/medication/sync
    - Return updated JSON list
    - Update Local Storage / SQLite
15. Device is now ready to trigger alarm at 08:00

---

#### 4.4.4 SOS Emergency Alert Component

**Figure 19 – Sequence Diagram of SOS Component**

*(Reference: alldiagram.pdf Page 16)*

**Actors/Objects**: Elderly User → Client App (UI/Logic) → Device Hardware (Audio/GPS) → Backend Server → Caregiver

**Flow** (REQ-SOS-02: False Alarm Prevention):
1. User long presses (3s) OR double taps SOS button
2. Device plays loud siren sound
3. Client starts 5-second countdown (REQ-SOS-03)
4. **[User cancels within 5 seconds]**:
   - User clicks [Cancel] button
   - Stop siren
   - Alert cancelled
5. **[Countdown expires (5 seconds passed)]**:
   - Stop siren
   - Request simulated GPS location
   - Return coordinates (Lat, Long)
   - Build payload: UserID, Timestamp, Location (REQ-SOS-04)
   - POST /api/sos/alert (Payload)
   - **Parallel processing**:
     - Send push notification / SMS to caregiver
     - Caregiver receives: "Emergency! User [ID] at [Location]"
     - Log emergency event in database
   - Return 200 OK (Alert Sent)
   - Display "Help is on the way!"

---

#### 4.4.5 Caregiver Dashboard - Health Analytics Component

**Figure 20 – Sequence Diagram of Caregiver Dashboard Component**

*(Reference: alldiagram.pdf Page 17)*

**Pre-condition**: HTTPS Connection Established, Security & Privacy Requirements met

**Actors/Objects**: Caregiver User → Web Dashboard (Browser) → Backend System (Python/Node.js) → Database (SQLite/Firebase)

**Flow**:
1. Caregiver accesses dashboard URL and logs in
2. POST /auth/login (Email, Password)
3. Backend validates credentials
4. User validated → Return session token
5. Caregiver clicks "View Health Reports"
6. **Requesting Analytics Data**:
   - GET /api/caregiver/dashboard?patientID=123
7. **Processing REQ-DASH-01 (Adherence)**:
   - SELECT * FROM Logs WHERE type='MED' AND date >= 30_days_ago
   - Return list [{ID, Status: TAKEN/MISSED, Timestamp}]
8. **Processing REQ-DASH-03 (Mood Trend)**:
   - SELECT * FROM Logs WHERE type='MOOD' AND date >= 7_days_ago
   - Return list [{ID, SentimentScore, Timestamp}]
9. Backend aggregates data into JSON format
10. Return JSON payload (Medication + Mood Data)
11. **Visualization Logic**:
    - Parse JSON response
    - **[If data available]**:
      - Render calendar view (Green ticks for Taken, Red cross for Missed)
      - Render line graph (Mood Score 0-10 vs Time)
      - Display full dashboard
    - **[If no data found]**:
      - Display "No records found" empty state

---

#### 4.4.6 Elderly Mood Recording Component

**Figure 21 – Sequence Diagram of Mood Recording Component**

*(Reference: alldiagram.pdf Page 18)*

**Scenario**: Mood captured through AI conversation

**Actors/Objects**: Elderly User → Client UI (Tablet) → Web Speech API → Backend System → Database

**Flow**:
1. Trigger greeting (time-based: "Good Morning")
2. Request TTS
3. Audio: "Good morning! How are you feeling today?"
4. User speaks: "I feel a bit sad and dizzy"
5. Visual: Pulsing waveform animation
6. Send audio stream to Web Speech API
7. Return transcript: "I feel a bit sad and dizzy"
8. Display "Thinking..." / "Sedang fikir..."
9. POST /api/conversation (text, userID)
10. Parse keywords (Sentiment Analysis):
    - Detected: "Sad" (Mood), "Dizzy" (Health Symptom)
11. INSERT INTO DailyLogs (MoodScore, Keywords, Time)
12. Updates Mood Trend for Caregiver Dashboard
13. Acknowledge (Log Saved)
14. Generate empathetic response
15. Return JSON: {response: "I understand. Please rest...", tone: "soft"}
16. Request TTS (Response Text)
17. Audio output (Empathetic voice)

---

#### 4.4.7 Data Synchronization Component

**Figure 22 – Sequence Diagram of Data Synchronization**

*(Reference: alldiagram.pdf Page 18)*

**Scenario**: User takes medication while offline (Robustness & Safety Log)

**Actors/Objects**: Elderly User → Client UI (Tablet) → Local Storage / SQLite → Network Handler → Backend API → Cloud Database

**Flow**:
1. User taps "TAKEN" button (Medication Reminder)
2. Check network status
3. Connection failed (OFFLINE)
4. **Safety Req 5.2**: Data Persistence - Save to non-volatile storage immediately
5. INSERT Log (med_id: 101, status: "TAKEN", sync: false)
6. Success acknowledgment
7. Show "Saved (Offline Mode)" notification
8. **... Time passes (Connection Restored) ...**
9. Network handler detects "Online" event
10. Fetch logs where sync == false
11. Return list [Log_101]
12. **Loop** for each unsynced log:
    - **Security Req 5.3**: Encrypted HTTPS transmission
    - POST /api/meds/log (JSON Payload)
    - INSERT/UPDATE Health Record
    - Commit success
    - HTTP 200 OK (Acknowledged)
    - UPDATE Log SET sync = true
    - Success

---

### 4.5 Context Viewpoints

Use case diagrams showing system actors and their interactions.

#### 4.5.1 Design Concern

Concern of the context viewpoint is to determine properties of users and their interactions with the system. Clear definition of user capabilities ensures efficient implementation.

#### 4.5.2 Design Elements - Use Case Diagrams

##### 4.5.2.1 Use Case Diagram - Elderly User

**Figure 23 – Use Case Diagram of Elderly User**

*(Reference: alldiagram.pdf Page 19)*

**Actor**: Elderly User

**System**: SamaRasa System (Client App)

**Use Cases**:

| Use Case | Description | Relationships |
|----------|-------------|---------------|
| Chat with AI Companion | Engage in conversation with AI | «include» Log Daily Mood, «include» Provide Voice Input (STT), «extend» Switch to Quiet Mode (Text-only) |
| Respond to Medication Reminder | React to medication alerts | «extend» Skip Medication, «extend» Confirm Medication Taken |
| Trigger SOS Alert | Activate emergency help | «include» Send Location & ID, «extend» Cancel Alert (During Countdown) |
| Complete Fall Risk Assessment | Answer safety questionnaire | - |
| Switch Language (EN/MS) | Toggle between languages | - |
| Log Daily Mood | Record emotional state | Triggered by Timer with Audio Loop [REQ-MED-03] |

**Notes**:
- Medication Reminder: Triggered by Timer with Audio Loop [REQ-MED-03]
- SOS Alert: Trigger via Long Press or Double Tap [REQ-SOS-02]

---

##### 4.5.2.2 Use Case Diagram - Caregiver

**Figure 24 – Use Case Diagram of Caregiver**

*(Reference: alldiagram.pdf Page 20)*

**Actor**: Caregiver

**System**: SamaRasa System (Caregiver Portal)

**Pre-conditions**:
- Requires Email/Password [SRS Section 5.3]
- Includes User ID & GPS [SRS REQ-SOS-04]

**Use Cases**:

| Use Case | Description | Relationships |
|----------|-------------|---------------|
| Login / Authenticate | Secure access to portal | «include» Manage Medication Schedule |
| Receive Emergency Alert (SOS) | Get notified of emergencies | - |
| Receive Missed Dose Alert | Get notified of missed medications | - |
| Manage Medication Schedule | Configure medications | «extend» Add New Medication, «extend» Edit/Delete Schedule |
| View Health Dashboard | Access health data | «extend» View Medication Adherence (Past 30 Days), «extend» View Mood Trends, «extend» Remotely update schedule [SRS REQ-DASH-02] |

---

### 4.6 Composition Viewpoints

#### 4.6.1 Design Concerns

This viewpoint states information related to planning, monitoring, and controlling the project. To give an early view of the logical software components, we provide a component diagram.

#### 4.6.2 Design Elements - Component Diagram

**Figure 25 – Component Diagram**

*(Reference: alldiagram.pdf Page 20)*

```
                    ┌────────────────┐
                    │ Web Speech API │
                    │ Uses (STT/TTS) │
                    └───────┬────────┘
                            │
       ╔════════════════════╧════════════════════════════════════════════╗
       ║                 Client: Elderly App                              ║
       ║  ┌──────────────┐  ┌──────────────────┐  ┌────────────────┐     ║
       ║  │ Voice Handler│  │ Medication       │  │ SOS & Safety   │     ║
       ║  └──────┬───────┘  │ Manager          │  └────────┬───────┘     ║
       ║         │          └────────┬─────────┘           │             ║
       ║         │ Text/Audio Stream │ Log Adherence       │ Trigger     ║
       ║         ▼                   │                     │ Emergency   ║
       ║  ┌──────────────┐           │                     │             ║
       ║  │ Chat         │◄──────────┴─────────────────────┘             ║
       ║  │ Companion    │ Mood & Conversation                           ║
       ║  └──────────────┘                                               ║
       ╚═════════════════════════════════════════════════════════════════╝
                            │
                            │
       ╔════════════════════╧════════════════════════════════════════════╗
       ║                 Client: Caregiver Portal                         ║
       ║  ┌──────────────────┐  ┌─────────────┐                          ║
       ║  │ Schedule Config  │  │ Dashboard   │                          ║
       ║  └────────┬─────────┘  └──────┬──────┘                          ║
       ║           │ Update Schedule    │ View Logs                      ║
       ║           └───────────┬────────┘                                ║
       ║                       │ Trigger on Missed Dose / Trigger on SOS ║
       ╚═══════════════════════╪═════════════════════════════════════════╝
                               │
                               ▼
       ╔═══════════════════════════════════════════════════════════════════╗
       ║                     Backend Server                                 ║
       ║  ┌──────────────────┐                                             ║
       ║  │ API Controller   │                                             ║
       ║  └────────┬─────────┘                                             ║
       ║           │ Read/Write Data    │ Get Response    │ Send Alert     ║
       ║           ▼                    ▼                 ▼                ║
       ║  ┌────────────────┐  ┌──────────────┐  ┌───────────────────┐     ║
       ║  │ Database       │  │ AI Logic     │  │ Notification      │     ║
       ║  │ (SQLite)       │  │ Engine       │  │ Service           │     ║
       ║  └────────────────┘  └──────────────┘  └───────────────────┘     ║
       ╚═══════════════════════════════════════════════════════════════════╝
```

**Component Descriptions**:

| Component | Type | Description | Dependencies |
|-----------|------|-------------|--------------|
| Voice Handler | Module | Processes voice input/output | Web Speech API |
| Chat Companion | Module | Manages AI conversation and mood detection | Voice Handler, AI Logic Engine |
| Medication Manager | Module | Handles medication scheduling and reminders | Database, Notification Service |
| SOS & Safety | Module | Manages emergency alerts | API Controller, Notification Service |
| Schedule Config | Module | Allows caregivers to configure medications | API Controller, Database |
| Dashboard | Module | Displays health analytics and logs | API Controller, Database |
| API Controller | Component | Routes requests and handles business logic | All modules |
| Database (SQLite) | Data Store | Persistent storage for all data | - |
| AI Logic Engine | Service | Processes sentiment and generates responses | Database |
| Notification Service | Service | Sends SMS/Email alerts | - |

---

## 5. Requirements Matrix

This matrix traces functional requirements from the SRS to design components.

**UC** = Use Case from SRS

| Use Case ID | Description | Login | Chat | Medication | SOS | Dashboard | Risk Assessment |
|-------------|-------------|-------|------|------------|-----|-----------|-----------------|
| REQ-CHAT-01 | Time-based greeting | | X | | | | |
| REQ-CHAT-02 | Voice capture & STT | | X | | | | |
| REQ-CHAT-03 | Sentiment analysis | | X | | | | |
| REQ-CHAT-04 | Voice fallback (<60% confidence) | | X | | | | |
| REQ-CHAT-05 | Quiet mode (text-only) | | X | | | | |
| REQ-MED-01 | Full-screen reminder alert | | | X | | | |
| REQ-MED-02 | Alert with pill info & buttons | | | X | | | |
| REQ-MED-03 | Audio loop every 30s | | | X | | | |
| REQ-MED-04 | Escalation after 15 min | | | X | | X | |
| REQ-MED-05 | Log medication status | | | X | | X | |
| REQ-SOS-01 | Fixed SOS button position | | | | X | | |
| REQ-SOS-02 | Long press / double tap activation | | | | X | | |
| REQ-SOS-03 | 5-second countdown with siren | | | | X | | |
| REQ-SOS-04 | Alert payload (ID, time, GPS) | | | | X | X | |
| REQ-DASH-01 | Adherence calendar view (30 days) | X | | | | X | |
| REQ-DASH-02 | Remote schedule management | X | | X | | X | |
| REQ-DASH-03 | Mood trend visualization | | X | | | X | |
| REQ-RISK-01 | Questionnaire wizard | | | | | | X |
| REQ-RISK-02 | Risk score calculation | | | | | | X |
| REQ-SEC-01 | Caregiver authentication | X | | | | X | |

---

## End of Document

---

**Document Information:**
- **Project**: SamaRasa - AI-Powered Companion System
- **Course**: SSW3001 Software Engineering
- **Semester**: 1 2025/2026
- **University**: Universiti Putra Malaysia
- **Submission**: Assignment 2 - Software Design Document (SDD)
