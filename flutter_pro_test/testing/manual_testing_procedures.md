# 📋 CareNow MVP - Manual Android Device Testing Procedures

## 🎯 Overview

This document provides comprehensive manual testing procedures for validating CareNow MVP functionality on real Android devices. These procedures complement automated tests and focus on user experience validation, edge cases, and real-world scenarios.

## 📱 Pre-Testing Setup

### Device Preparation Checklist
- [ ] Device fully charged (>80%)
- [ ] Latest Android security updates installed
- [ ] Sufficient storage space (>2GB free)
- [ ] Stable internet connection (WiFi + Mobile data)
- [ ] Notification permissions enabled
- [ ] Location services enabled
- [ ] Camera and microphone permissions available
- [ ] Test APK installed with secure environment configuration

### Test Environment Verification
- [ ] Firebase project: `carenow-app-2024` accessible
- [ ] Test user accounts created and verified
- [ ] Payment test cards configured
- [ ] Admin dashboard accessible
- [ ] Test data populated in Firestore

## 🧪 Manual Test Procedures

### 1. Client App Testing

#### 1.1 Registration & Authentication Flow
**Test ID**: MANUAL-CLIENT-AUTH-001  
**Duration**: 10 minutes  
**Priority**: Critical

**Pre-conditions**:
- Fresh app installation
- Valid Vietnamese phone number available
- Email account accessible

**Test Steps**:
1. **Launch App**
   - [ ] App launches without crashes
   - [ ] Splash screen displays correctly
   - [ ] Loading indicators work properly
   - [ ] Vietnamese language detected automatically

2. **Phone Registration**
   - [ ] Enter Vietnamese phone number (+84 format)
   - [ ] Phone number validation works
   - [ ] OTP request sent successfully
   - [ ] OTP received within 60 seconds
   - [ ] OTP verification successful
   - [ ] Error handling for invalid OTP

3. **Profile Setup**
   - [ ] Profile form displays correctly
   - [ ] Vietnamese name input works
   - [ ] Address autocomplete functional
   - [ ] Profile photo upload works
   - [ ] Data validation appropriate
   - [ ] Profile saved successfully

**Expected Results**:
- ✅ Smooth registration flow
- ✅ Vietnamese localization correct
- ✅ All form validations working
- ✅ Profile data persisted in Firebase
- ✅ User redirected to home screen

**Pass/Fail Criteria**:
- **Pass**: All steps completed without critical errors
- **Fail**: App crashes, data not saved, or critical functionality broken

---

#### 1.2 Service Booking Workflow
**Test ID**: MANUAL-CLIENT-BOOK-001  
**Duration**: 20 minutes  
**Priority**: Critical

**Pre-conditions**:
- Client logged in successfully
- Available partners in system
- Payment method configured

**Test Steps**:
1. **Service Selection**
   - [ ] Home screen loads with service categories
   - [ ] "Chăm sóc người già" service visible
   - [ ] Service details display correctly
   - [ ] Pricing information accurate
   - [ ] Service description in Vietnamese

2. **Date & Time Selection**
   - [ ] Calendar widget displays correctly
   - [ ] Available dates highlighted
   - [ ] Time slots show availability
   - [ ] Past dates disabled
   - [ ] Selection persists correctly

3. **Partner Selection**
   - [ ] Available partners listed
   - [ ] Partner profiles display (photo, rating, experience)
   - [ ] Rating system visible
   - [ ] Partner location information shown
   - [ ] "Auto-assign" option available

4. **Service Details**
   - [ ] Address input field functional
   - [ ] Address autocomplete works
   - [ ] Special instructions field available
   - [ ] Duration selection works
   - [ ] Price calculation accurate

5. **Booking Confirmation**
   - [ ] Booking summary displays correctly
   - [ ] All details accurate
   - [ ] Terms and conditions accessible
   - [ ] Confirm button functional

6. **Payment Processing**
   - [ ] Payment screen loads
   - [ ] Stripe integration works
   - [ ] Test card accepted
   - [ ] Payment processing feedback
   - [ ] Success confirmation displayed

**Expected Results**:
- ✅ Seamless booking flow
- ✅ Accurate price calculations
- ✅ Payment processing successful
- ✅ Booking confirmation received
- ✅ Partner notified automatically

---

#### 1.3 Real-time Booking Tracking
**Test ID**: MANUAL-CLIENT-TRACK-001  
**Duration**: 15 minutes  
**Priority**: High

**Test Steps**:
1. **Booking Status Monitoring**
   - [ ] Navigate to "My Bookings"
   - [ ] Current booking displays with status
   - [ ] Status updates in real-time
   - [ ] Progress indicators work
   - [ ] Estimated time displayed

2. **Notification Testing**
   - [ ] Partner acceptance notification received
   - [ ] Service start notification received
   - [ ] Service completion notification received
   - [ ] Notification actions work (View Details)
   - [ ] Deep linking functional

3. **Communication Features**
   - [ ] Contact partner button works
   - [ ] In-app messaging functional (if available)
   - [ ] Emergency contact accessible

**Expected Results**:
- ✅ Real-time status updates
- ✅ Timely notifications
- ✅ Communication channels work
- ✅ Booking history accurate

---

### 2. Partner App Testing

#### 2.1 Partner Registration & Profile Setup
**Test ID**: MANUAL-PARTNER-REG-001  
**Duration**: 15 minutes  
**Priority**: Critical

**Test Steps**:
1. **Registration Process**
   - [ ] Partner registration option available
   - [ ] Identity verification process clear
   - [ ] Document upload functional
   - [ ] Profile photo upload works
   - [ ] Service selection interface intuitive

2. **Profile Configuration**
   - [ ] Service categories selectable
   - [ ] Experience level input
   - [ ] Availability schedule setup
   - [ ] Service area configuration
   - [ ] Pricing setup (if applicable)

3. **Verification Process**
   - [ ] Verification status displayed
   - [ ] Required documents listed
   - [ ] Upload progress indicators
   - [ ] Verification feedback provided

**Expected Results**:
- ✅ Complete profile setup
- ✅ Document uploads successful
- ✅ Verification process initiated
- ✅ Profile data saved correctly

---

#### 2.2 Job Queue Management
**Test ID**: MANUAL-PARTNER-JOB-001  
**Duration**: 20 minutes  
**Priority**: Critical

**Test Steps**:
1. **Job Queue Interface**
   - [ ] Available jobs displayed
   - [ ] Job details comprehensive
   - [ ] Distance/location information
   - [ ] Estimated earnings shown
   - [ ] Job priority indicators

2. **Job Acceptance Flow**
   - [ ] Accept/Decline buttons functional
   - [ ] Acceptance confirmation dialog
   - [ ] Job details accessible after acceptance
   - [ ] Client contact information provided
   - [ ] Navigation assistance available

3. **Job Status Management**
   - [ ] "Start Service" button works
   - [ ] Status update notifications sent
   - [ ] "Complete Service" functionality
   - [ ] Service report submission
   - [ ] Photo upload for completion proof

4. **Earnings Tracking**
   - [ ] Earnings calculated correctly
   - [ ] Commission deduction accurate
   - [ ] Payment schedule information
   - [ ] Earnings history accessible

**Expected Results**:
- ✅ Smooth job management flow
- ✅ Accurate earnings calculations
- ✅ Real-time status updates
- ✅ Client notifications sent

---

### 3. Admin Dashboard Testing (Mobile Browser)

#### 3.1 Mobile Dashboard Access
**Test ID**: MANUAL-ADMIN-MOB-001  
**Duration**: 15 minutes  
**Priority**: High

**Test Steps**:
1. **Mobile Browser Access**
   - [ ] Dashboard URL accessible on mobile
   - [ ] Responsive design works
   - [ ] Login form functional
   - [ ] Authentication successful

2. **Dashboard Navigation**
   - [ ] Menu navigation works
   - [ ] Charts render correctly
   - [ ] Tables responsive on mobile
   - [ ] Touch interactions smooth

3. **Real-time Monitoring**
   - [ ] Live booking updates
   - [ ] User activity monitoring
   - [ ] System health metrics
   - [ ] Performance indicators

**Expected Results**:
- ✅ Mobile-responsive dashboard
- ✅ All features accessible
- ✅ Real-time data updates
- ✅ Smooth mobile experience

---

## 🔄 Cross-Role Integration Testing

### End-to-End Workflow Validation
**Test ID**: MANUAL-E2E-001  
**Duration**: 45 minutes  
**Priority**: Critical

**Required Setup**:
- Device A: Client app
- Device B: Partner app
- Device C: Admin dashboard (mobile browser)

**Test Procedure**:
1. **Booking Creation (Device A)**
   - [ ] Client creates elder care booking
   - [ ] Payment processed successfully
   - [ ] Booking status: "Pending"

2. **Partner Notification (Device B)**
   - [ ] Partner receives job notification
   - [ ] Notification details accurate
   - [ ] Partner accepts job

3. **Admin Monitoring (Device C)**
   - [ ] Admin sees new booking in dashboard
   - [ ] Real-time status updates visible
   - [ ] Partner assignment confirmed

4. **Service Execution (Device B)**
   - [ ] Partner starts service
   - [ ] Status updates to "In Progress"
   - [ ] Client receives start notification

5. **Service Completion (Device B)**
   - [ ] Partner completes service
   - [ ] Completion report submitted
   - [ ] Status updates to "Completed"

6. **Client Feedback (Device A)**
   - [ ] Client receives completion notification
   - [ ] Rating system accessible
   - [ ] Review submission works

7. **Payment & Earnings (All Devices)**
   - [ ] Payment processed to partner
   - [ ] Earnings updated correctly
   - [ ] Transaction recorded in admin

**Success Criteria**:
- ✅ All three roles interact seamlessly
- ✅ Real-time updates across all devices
- ✅ Data consistency maintained
- ✅ No data loss or corruption
- ✅ All notifications delivered

---

## 🌐 Edge Cases & Error Scenarios

### Network Connectivity Testing
**Test ID**: MANUAL-NETWORK-001  
**Duration**: 20 minutes

**Test Scenarios**:
1. **Offline Mode**
   - [ ] Disable internet connection
   - [ ] Test cached data access
   - [ ] Verify offline indicators
   - [ ] Test data queuing

2. **Poor Connection**
   - [ ] Simulate slow network
   - [ ] Test loading states
   - [ ] Verify timeout handling
   - [ ] Check retry mechanisms

3. **Connection Recovery**
   - [ ] Restore internet connection
   - [ ] Verify data synchronization
   - [ ] Check queued operations
   - [ ] Validate data integrity

### Device-Specific Testing
**Test ID**: MANUAL-DEVICE-001  
**Duration**: 30 minutes

**Test Areas**:
1. **Screen Orientations**
   - [ ] Portrait mode functionality
   - [ ] Landscape mode support
   - [ ] Rotation handling smooth

2. **Different Screen Sizes**
   - [ ] Small screens (5-5.5 inch)
   - [ ] Medium screens (5.5-6.5 inch)
   - [ ] Large screens (6.5+ inch)

3. **Hardware Features**
   - [ ] Camera integration
   - [ ] GPS/Location services
   - [ ] Push notifications
   - [ ] Background processing

## 📊 Test Results Documentation

### Test Execution Tracking
For each test procedure, document:
- [ ] Test ID and name
- [ ] Device information (model, Android version, screen size)
- [ ] Test execution date and time
- [ ] Tester name
- [ ] Pass/Fail status
- [ ] Screenshots of key steps
- [ ] Issues found (with severity)
- [ ] Performance observations
- [ ] User experience notes

### Bug Reporting Template
**Bug ID**: BUG-YYYY-MM-DD-XXX  
**Severity**: Critical/High/Medium/Low  
**Priority**: P1/P2/P3/P4  
**Device**: [Device model and Android version]  
**Steps to Reproduce**: [Detailed steps]  
**Expected Result**: [What should happen]  
**Actual Result**: [What actually happened]  
**Screenshots**: [Attach relevant screenshots]  
**Additional Notes**: [Any other relevant information]

---

**Next**: Test Execution Scripts and Performance Monitoring
