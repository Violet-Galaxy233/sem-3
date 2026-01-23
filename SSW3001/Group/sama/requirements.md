# SamaRasa — Software Requirements Specification (SRS)

## 1. Introduction

### 1.1 Purpose
Define all functional and non-functional requirements for **SamaRasa**, an AI-powered bilingual (BM/EN) assistant supporting Malaysia’s ageing society.

### 1.2 Scope
- Voice-interactive, elderly-friendly AI system.  
- Covers health management, medication reminders, companionship, and caregiver alerts.  
- Prototype built using **Figma + Python + JS**; aligns with **MOH National Policy for Older Persons (2024)**.

### 1.3 Stakeholders
| Role | Description |
|------|--------------|
| Elderly users | Primary end-users interacting via voice/UI |
| Caregivers | Monitor elderly well-being through dashboard |
| Developers | Implement system logic and prototype |
| System testers | Validate usability and correctness |

### 1.4 References
- DOSM (2025) — Malaysia Ageing Report  
- WHO (2023) — Global Report on Ageing and Health  
- MOH (2024) — National Policy for Older Persons  

---

## 2. Overall Description

### 2.1 System Overview
SamaRasa integrates multiple modules:
- **AI Chat Companion**
- **Medication Reminder**
- **Health Diary**
- **Fall Risk Assessment**
- **Emergency Alert (SOS)**
- **Family Dashboard**

### 2.2 Constraints
- Prototype only; no real API or IoT integration.  
- Duration: 14 weeks.  
- Must support dual-language and accessibility features.

### 2.3 Assumptions
- Elderly users possess basic digital literacy.  
- Caregivers access system via web dashboard.  
- Stable local network or offline simulation acceptable.

---

## 3. Functional Requirements

### FR-1: AI Chat Companion
- **Input:** Text/voice from elderly user  
- **Process:** Rule-based conversational logic  
- **Output:** Voice/text response + reminder  
- **Priority:** High

### FR-2: Medication Reminder
- **Input:** Schedule (time, dosage)  
- **Output:** Voice + visual alert, with confirmation button  
- **Data:** Stored locally  
- **Priority:** High

### FR-3: Health Diary
- **Input:** Mood, sleep, exercise entries  
- **Output:** Weekly summary chart  
- **Priority:** Medium

### FR-4: Fall Risk Assessment
- **Input:** Questionnaire (10 items)  
- **Process:** Calculate score (Low/Medium/High risk)  
- **Output:** Suggestions for exercises or precautions  
- **Priority:** Medium

### FR-5: Emergency Alert (SOS)
- **Input:** One-button trigger  
- **Process:** Simulated notification to caregiver  
- **Output:** Alert message  
- **Priority:** Critical

### FR-6: Family Dashboard
- **Input:** Linked elderly ID  
- **Output:** Display diary logs, reminders, fall risk  
- **Platform:** Web  
- **Priority:** High

---

## 4. Non-Functional Requirements

| Type | Requirement |
|------|--------------|
| Usability | ≤ 2 navigation layers, large fonts, simple icons |
| Accessibility | Dual-language (BM/EN), text-to-speech |
| Performance | Response time ≤ 2s |
| Reliability | 95% uptime (simulation) |
| Security | Local data encrypted (mock) |
| Maintainability | Modular MVC architecture |
| Compliance | Follows MOH 2024 elderly policy |

---

## 5. UI / UX Requirements

- **Home screen:** AI chat + shortcut icons  
- **Font size:** ≥18pt  
- **Color contrast:** WCAG 2.1 compliant  
- **Voice input:** Microphone button + animation feedback  
- **Navigation depth:** Max 2 levels  
- **Icons:** ≥48px, labeled with text  

---

## 6. System Architecture

```
User Interface (View)
   ↑ ↓
Controller Layer (Logic)
   ↑ ↓
Data Storage (Model)
```

### Components
| Module | Function | Tech |
|---------|-----------|------|
| Chatbot | Empathy dialogue | Python |
| Reminder | Notifications | JS/Python |
| Diary | Data input | Local DB |
| Fall Risk | Scoring | Python |
| SOS | Alerts | JS mock API |
| Dashboard | Monitoring | Figma/Web |

---

## 7. External Interfaces

| Type | Description |
|------|--------------|
| Hardware | Touchscreen, microphone |
| Software | Local DB / Mock API |
| Communication | Local Wi-Fi simulation |
| User | Elderly and caregiver interfaces |

---

## 8. Project Schedule

| Week | Task | Deliverable |
|------|------|-------------|
| 1–2 | Brainstorm, roles | Concept finalized |
| 3 | Proposal | Assignment 1 |
| 4–6 | Requirement gathering | Interviews & notes |
| 7 | SRS | Assignment 2 |
| 8–11 | System design | Wireframes, diagrams |
| 12 | SDD | Assignment 3 |
| 13–14 | Prototype | Figma mockup |

---

## 9. Team Roles

| Name | ID | Role | Responsibility |
|------|----|------|----------------|
| Yue Chenghao | 227154 | Project Manager | Architecture, coordination |
| Zhao Yunu | 227225 | UI/UX | Wireframes, storyboards |
| Fan Haoqi | 227259 | Front-End | Interface implementation |
| Hua Jie | 226758 | Testing | QA, validation |
| Wang Kailun | 227046 | Back-End | AI logic, data flow |
| Zhang Yaoyuan | 226557 | AI Interaction | Chat design |

---

## 10. Acceptance Criteria

- Prototype demonstrates all six modules.  
- Bilingual UI and voice feedback functional.  
- User testing with ≥2 elderly participants.  
- Documentation aligned with IEEE SRS format.  

---

## 11. Future Enhancements
- Real API integration for emergency alerts.  
- Machine-learning based mood detection.  
- Cloud-based caregiver monitoring dashboard.  

---

## 12. Appendix

### Tools & Frameworks
- **Figma** (UI prototyping)  
- **Python + Flask (mock backend)**  
- **SQLite** (local storage)  
- **HTML/CSS/JS** (frontend logic)  

### References
Adapted from the **SamaRasa Group Proposal (SSW3001, UPM 2025)**.
