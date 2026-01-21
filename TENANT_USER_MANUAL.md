# TENX Facility ERP - Tenant User Manual

**Version:** 1.0  
**Date:** January 2025  
**Application:** TENX Facility ERP System

---

## Table of Contents

1. [Introduction](#introduction)
2. [System Access](#system-access)
3. [Login Process](#login-process)
4. [Tenant Dashboard Overview](#tenant-dashboard-overview)
5. [Creating Maintenance Requests](#creating-maintenance-requests)
6. [Viewing Your Complaints](#viewing-your-complaints)
7. [Notifications](#notifications)
8. [Profile Management](#profile-management)
9. [Troubleshooting](#troubleshooting)
10. [Best Practices](#best-practices)

---

## Introduction

Welcome to the **TENX Facility ERP System** - a comprehensive facility management platform designed to help tenants submit maintenance requests, track their status, and communicate with facility management teams.

This manual provides step-by-step instructions for tenant users to effectively use the system. As a tenant, you can create maintenance requests (complaints), view their status, receive notifications, and manage your profile.

### System Requirements

- **Web Browser:** Chrome, Firefox, Safari, or Edge (latest versions)
- **Mobile Device:** iOS or Android (for mobile app, if available)
- **Screen Resolution:** Minimum 1280x720 (1920x1080 recommended for desktop)
- **Internet Connection:** Stable connection required

### Tenant Credentials

For this manual, we'll use the following example credentials:

- **Username:** `tenant_user`
- **Password:** `password123`
- **Company Code:** `ALOS`

**Note:** Your actual credentials will be provided by your facility administrator. Contact them if you need assistance with login credentials.

---

## System Access

### Accessing the Application

1. Open your web browser or mobile app
2. Navigate to the TENX application URL (provided by your facility administrator)
3. The application will load the **Company Selection** screen

---

## Login Process

The login process consists of two steps:

### Step 1: Company Selection

1. **Locate the Company Code Field**

   - On the right side of the screen (desktop) or at the top (mobile), you'll see a white form card
   - Find the "Company Code" input field

2. **Enter Company Code**

   - Type your company code: `ALOS` (or your facility's company code)
   - The field accepts alphanumeric characters (not UUID format)
   - Company codes are typically short, memorable codes provided by your facility

3. **Continue**
   - Click the orange "Continue" button or press Enter
   - The system validates the company code
   - If valid, you'll be redirected to the Login page

![Company Selection Screen](screenshots/01-company-selection.png)

**Note:** If you enter an invalid company code, you'll see an error message: "Invalid company code. Please check and try again."

---

### Step 2: User Login

1. **Enter Credentials**

   - **Username Field:** Enter your username (e.g., `tenant_user`)
     - **Important:** Tenants use **username**, not email address
     - Your username is provided by your facility administrator
   - **Password Field:** Enter your password
     - Password field has a visibility toggle (eye icon) to show/hide the password

2. **Login**
   - Click the orange "Login" button
   - The system validates your credentials
   - Upon successful authentication, you'll be redirected to the Tenant Dashboard

![Login Screen](screenshots/03-login-page.png)

**Additional Options:**

- **Forgot Password?** - Click the link below the password field to reset your password
- **Switch Site** - Click the "SWITCH SITE" button to change your company code

**Important Notes:**

- Username and password are case-sensitive
- Make sure you're using the correct company code for your facility
- If you've forgotten your password, use the "Forgot Password?" link to reset it

---

## Tenant Dashboard Overview

After successful login, you'll land on the **Tenant Dashboard**. This is your central hub for managing maintenance requests and staying informed about your facility.

### Dashboard Components

The Tenant Dashboard displays:

1. **Header Section**

   - Personalized greeting: "Good Morning/Afternoon/Evening, [Your Name]"
   - Company name: "Welcome back to [Company Name]"
   - User avatar (clickable to access profile)
   - Notification bell icon (top right) showing unread notification count
   - Villa information: Displays your villa number(s) (e.g., "Villa 101 • Tenant Portal")

2. **Activity Feed Section**

   - Lists all your maintenance requests (complaints)
   - Each ticket shows:
     - Ticket ID (e.g., TKT-2026-0004)
     - Title/Description
     - Status badge (New, In Progress, Completed, On Hold, etc.)
     - Priority level (Low, Medium, High, Critical)
     - Villa number
     - Creation date and time
     - Time elapsed (e.g., "1d ago")
   - Pull down to refresh the list

3. **Create Ticket Button**

   - Floating action button (FAB) at the bottom right
   - Orange button with "+" icon and "Create Ticket" label
   - Tap/click to create a new maintenance request

### Dashboard Features

- **Pull to Refresh:** Pull down on the activity feed to refresh your tickets
- **Real-time Updates:** Your tickets update automatically as technicians work on them
- **Responsive Design:** Dashboard adapts to your screen size (Desktop/Tablet/Mobile)
- **Quick Access:** Tap your avatar to access your profile
- **Notifications:** Tap the bell icon to view all notifications

**Visual Guide:** The tenant dashboard displays a personalized header with your name and company, followed by an activity feed showing all your maintenance requests. The floating action button allows you to quickly create new tickets.

---

## Creating Maintenance Requests

As a tenant, you can create maintenance requests (complaints) to report issues with your villa or facility.

### Method 1: AI-Powered Ticket Creation (Recommended)

1. **Access Create Ticket Page**

   - From the Tenant Dashboard, click/tap the orange "Create Ticket" floating action button
   - You'll be taken to the AI-powered ticket creation page

2. **Describe Your Issue**

   - Use natural language to describe your maintenance issue
   - The AI will help categorize and structure your request
   - Examples:
     - "The air conditioning in my bedroom is not working"
     - "Water leak in the kitchen sink"
     - "Broken door handle on the main entrance"

3. **Review AI Suggestions**

   - The AI will suggest:
     - Ticket type/category
     - Priority level
     - Title and description
   - Review and modify as needed

4. **Select Location**

   - **Select Site:** Choose your facility/site (if multiple sites available)
   - **Select Space:** Choose your villa number or specific space

5. **Submit Request**
   - Click the "Submit Request" button
   - Your ticket will be created and assigned a ticket ID
   - You'll receive a confirmation notification

### Method 2: Standard Ticket Creation

1. **Access Create Ticket Page**

   - Navigate to `/tenant/complaints/create` (if available)
   - Or use the standard form option

2. **Fill in Ticket Information**

   **Describe the Issue Section:**

   - **Ticket Type:** Select from dropdown (e.g., Maintenance, Repair, Inspection)
   - **Title:** Enter a brief, descriptive title for the ticket
   - **Description:** Provide detailed information about the issue
     - Be specific about the problem
     - Include location details within your villa
     - Mention when the issue started (if known)

   **Location Section:**

   - **Select Site:** Choose the site/location from dropdown
   - **Select Space:** Choose your villa number or specific space

3. **Review Information**
   - Double-check all details before submitting
   - Ensure location is correct

4. **Submit Request**
   - Click the "Submit Request" button
   - Your ticket will be created and you'll be redirected to view it

**Best Practices for Creating Tickets:**

- **Be Specific:** Provide clear, detailed descriptions
- **Include Location:** Specify exactly where in your villa the issue is
- **Add Context:** Mention when the issue started or became noticeable
- **Use Photos:** If available, attach photos to help technicians understand the issue
- **Set Appropriate Priority:** Use High priority for urgent issues (safety, water leaks, etc.)

---

## Viewing Your Complaints

You can view all your maintenance requests (complaints) in several ways:

### From Dashboard

1. **Activity Feed**
   - Your dashboard shows all your tickets in the activity feed
   - Scroll to see older tickets
   - Pull down to refresh

2. **View Ticket Details**
   - Tap/click on any ticket in the activity feed
   - You'll see the full ticket details page

### From Complaints List Page

1. **Access Complaints List**
   - Navigate to `/tenant/complaints` (if available via menu)
   - Or access through the dashboard

2. **Filter Options**
   - Filter by status (New, In Progress, Completed, On Hold, etc.)
   - Search by ticket ID or description
   - Sort by date, priority, or status

3. **View Details**
   - Click on any ticket to view full details

### Ticket Detail Page

When viewing a ticket, you'll see:

- **Header:**
  - Ticket ID and title
  - Back button to return to list
  - Refresh button

- **Ticket Information:**
  - Full description
  - Current status with status badge
  - Priority level
  - Assigned technician (if assigned)
  - Villa/property information
  - Creation date and time
  - Last updated timestamp

- **Status History:**
  - Timeline of status changes
  - Who made each change (technician, admin)
  - When each change occurred

- **Comments and Updates:**
  - All comments from technicians and admins
  - Ability to add your own comments
  - File attachments (photos, documents)

- **Actions Available:**
  - Add comments to provide additional information
  - View technician responses
  - Track progress in real-time

---

## Notifications

The system sends notifications for important events related to your maintenance requests.

### Accessing Notifications

1. **Notification Bell**
   - Click/tap the bell icon in the dashboard header
   - A red dot indicates unread notifications
   - Number badge shows count of unread notifications

2. **Notification List Page**
   - View all notifications (read and unread)
   - Mark notifications as read
   - Filter by type or date

### Notification Types

You'll receive notifications for:

- **New Ticket Created:** Confirmation when you create a ticket
- **Status Updates:** When your ticket status changes (e.g., In Progress, Completed)
- **Technician Assignment:** When a technician is assigned to your ticket
- **Comments:** When technicians or admins add comments to your ticket
- **Resolutions:** When your ticket is marked as completed

### Managing Notifications

- **Mark as Read:** Tap/click on a notification to mark it as read
- **View Related Ticket:** Tap/click on a notification to view the related ticket
- **Clear All:** Option to mark all notifications as read (if available)

---

## Profile Management

You can manage your profile information and account settings.

### Accessing Your Profile

1. **From Dashboard**
   - Click/tap your avatar (circular icon with your initial) in the top left
   - Or navigate to `/profile`

2. **Profile Page**
   - View your personal information
   - Update your details
   - Change password
   - View account information

### Profile Features

**Personal Information:**
- View and update your name
- View your email address (if available)
- Update contact details
- View your villa number(s)

**Security & Password:**
- Change your password
- View security settings
- Manage account security

**Account Details:**
- View your account information
- See your role (Tenant)
- View account creation date

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Cannot Login

**Problem:** Login fails with error message

**Solutions:**

- Verify your username is correct (tenants use username, not email)
- Check that your password is entered correctly (case-sensitive)
- Ensure your company code is correct
- Clear browser cache and cookies
- Try a different browser
- Contact your facility administrator if issue persists

#### 2. Company Code Not Recognized

**Problem:** "Invalid company code" error

**Solutions:**

- Double-check the company code spelling (case-insensitive)
- Contact your facility administrator to verify the company code
- Ensure you're using the correct company code for your facility

#### 3. Dashboard Not Loading

**Problem:** Dashboard shows loading indicator or error

**Solutions:**

- Check your internet connection
- Refresh the page (F5 or Ctrl+R / Cmd+R)
- Clear browser cache
- Try logging out and logging back in
- Contact support if the issue persists

#### 4. Cannot Create Ticket

**Problem:** Unable to create a new maintenance request

**Solutions:**

- Ensure you've selected a valid location (site and space)
- Check that all required fields are filled
- Verify your internet connection
- Try refreshing the page
- Contact support if the issue persists

#### 5. Notifications Not Appearing

**Problem:** Not receiving notifications for ticket updates

**Solutions:**

- Check notification settings in your profile
- Ensure notifications are enabled in your browser/device settings
- Refresh the page to check for new notifications
- Clear browser cache
- Contact support if notifications are still not working

#### 6. Cannot View Ticket Details

**Problem:** Error when trying to view a ticket

**Solutions:**

- Check your internet connection
- Refresh the page
- Try logging out and logging back in
- Contact support if the issue persists

---

## Best Practices

### Security

1. **Password Management:**
   - Use a strong, unique password
   - Change passwords regularly
   - Never share your credentials
   - Log out when finished (especially on shared computers)

2. **Session Management:**
   - Log out properly when done
   - Don't leave your session open on unattended computers
   - Use secure networks when accessing the system

### Creating Effective Tickets

1. **Be Descriptive:**
   - Provide clear, detailed descriptions of issues
   - Include specific location within your villa
   - Mention when the issue started

2. **Use Appropriate Priority:**
   - **High/Critical:** Safety issues, water leaks, electrical problems, no heating/cooling
   - **Medium:** Non-urgent repairs, cosmetic issues
   - **Low:** Minor maintenance, routine requests

3. **Follow Up:**
   - Add comments if you have additional information
   - Respond to technician questions promptly
   - Mark tickets as resolved when issues are fixed

4. **Organization:**
   - Check your tickets regularly
   - Keep track of open tickets
   - Follow up on tickets that haven't been updated

### Communication

1. **Clear Communication:**
   - Use clear, professional language in ticket descriptions
   - Provide context and background information
   - Be specific about what you need

2. **Responsiveness:**
   - Respond to technician questions in a timely manner
   - Provide access information if technicians need to visit
   - Confirm when issues are resolved

---

## Keyboard Shortcuts

- **Tab:** Navigate between form fields
- **Enter:** Submit forms or confirm actions
- **Escape:** Close dialogs or cancel actions
- **F5 / Ctrl+R / Cmd+R:** Refresh page
- **Ctrl+F / Cmd+F:** Search (on pages with search functionality)

---

## Support & Contact

For technical support or questions:

- **Facility Administrator:** Contact your facility's administrator for account issues
- **In-App:** Use the help/support feature (if available)
- **Documentation:** Refer to additional system documentation

---

## Screenshots Reference

This section provides an overview of the key screens available for reference:

### Login Flow Screenshots

1. **Company Selection Screen** (`screenshots/01-company-selection.png`)
   - Shows the initial company code entry screen
   - Displays promotional content on the left and form on the right
   - Demonstrates the modern, clean UI design

2. **Company Selection with Form** (`screenshots/02-company-selection-filled.png`)
   - Shows the company code input field
   - Displays the validation and form structure
   - Illustrates the "Continue" button

3. **Login Screen** (`screenshots/03-login-page.png`)
   - Shows the login form after company selection
   - Displays username and password fields
   - Shows the "Forgot Password" and "Switch Site" options

### Tenant Dashboard Screenshots

4. **Tenant Dashboard Overview** (if available)
   - Personalized greeting and company name
   - Activity feed with maintenance requests
   - Floating action button for creating tickets
   - Notification bell with unread count

---

## Appendix

### Glossary

- **Ticket/Complaint:** A maintenance request or work order
- **Villa:** Your property or facility unit
- **Technician:** A user assigned to perform maintenance work
- **Tenant:** A property occupant or resident (you)
- **Status:** Current state of a ticket (New, In Progress, Completed, etc.)
- **Priority:** Importance level of a ticket (Low, Medium, High, Critical)

### System Information

- **Application Name:** TENX Facility ERP
- **Version:** 1.0
- **Powered By:** Helixsense
- **Primary Color:** #007be5 (Blue)

---

## Document History

| Version | Date         | Changes         | Author               |
| ------- | ------------ | --------------- | -------------------- |
| 1.0     | January 2025 | Initial release | System Documentation |

---

**End of Manual**

For the most up-to-date information, please refer to the online documentation or contact your facility administrator.

