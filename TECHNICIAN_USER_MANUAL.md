# TENX Facility ERP - Technician User Manual

**Version:** 1.0  
**Date:** January 2025  
**Application:** TENX Facility ERP System

---

## Table of Contents

1. [Introduction](#introduction)
2. [System Access](#system-access)
3. [Login Process](#login-process)
4. [Technician Dashboard Overview](#technician-dashboard-overview)
5. [Viewing Assigned Tickets](#viewing-assigned-tickets)
6. [Updating Ticket Status](#updating-ticket-status)
7. [Adding Comments and Notes](#adding-comments-and-notes)
8. [Notifications](#notifications)
9. [Profile Management](#profile-management)
10. [Troubleshooting](#troubleshooting)
11. [Best Practices](#best-practices)

---

## Introduction

Welcome to the **TENX Facility ERP System** - a comprehensive facility management platform designed to help technicians manage maintenance tickets, track work assignments, and communicate with facility management teams and tenants.

This manual provides step-by-step instructions for technicians to effectively use the system. As a technician, you can view assigned tickets, update ticket status, add comments and notes, receive notifications, and manage your profile.

### System Requirements

- **Web Browser:** Chrome, Firefox, Safari, or Edge (latest versions)
- **Mobile Device:** iOS or Android (for mobile app, if available)
- **Screen Resolution:** Minimum 1280x720 (1920x1080 recommended for desktop)
- **Internet Connection:** Stable connection required

### Technician Credentials

For this manual, we'll use the following example credentials:

- **Email:** `technician@example.com`
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

   - **Email Field:** Enter your email address (e.g., `technician@example.com`)
     - **Important:** Technicians use **email address**, not username
     - Your email is provided by your facility administrator
   - **Password Field:** Enter your password
     - Password field has a visibility toggle (eye icon) to show/hide the password

2. **Login**
   - Click the orange "Login" button
   - The system validates your credentials
   - Upon successful authentication, you'll be redirected to the Technician Dashboard

![Login Screen](screenshots/03-login-page.png)

**Additional Options:**

- **Forgot Password?** - Click the link below the password field to reset your password
- **Switch Site** - Click the "SWITCH SITE" button to change your company code

**Important Notes:**

- Email and password are case-sensitive
- Make sure you're using the correct company code for your facility
- If you've forgotten your password, use the "Forgot Password?" link to reset it

---

## Technician Dashboard Overview

After successful login, you'll land on the **Technician Dashboard**. This is your central hub for managing assigned maintenance tickets and tracking your work.

### Dashboard Components

The Technician Dashboard displays:

1. **Header Section**

   - Personalized greeting: "Good Morning/Afternoon/Evening, [Your Name]"
   - Your role badge: "Technician"
   - Current date (e.g., "Mon, 15 Jan")
   - User avatar (clickable to access profile)
   - Refresh button (on desktop) to manually reload dashboard data
   - Notification bell icon (if available) showing unread notification count

2. **Ticket Statistics Bar**

   - Shows summary of your assigned tickets:
     - **Assigned:** Number of tickets assigned to you
     - **In Progress:** Number of tickets you're currently working on
     - **Completed:** Number of tickets you've completed
   - Example: "5 Assigned • 2 In Progress • 10 Completed"

3. **Assigned Tickets List**

   - Lists all tickets assigned to you
   - Each ticket shows:
     - Ticket ID (e.g., TKT-2026-0004)
     - Title/Description
     - Status badge (Assigned, In Progress, Completed, On Hold, etc.)
     - Priority level (Low, Medium, High, Critical)
     - Villa number
     - Creation date and time
     - Time elapsed (e.g., "1d ago")
   - Pull down to refresh the list (mobile)
   - Click/tap on any ticket to view details

### Dashboard Features

- **Pull to Refresh:** Pull down on the ticket list to refresh your assignments (mobile)
- **Real-time Updates:** Your tickets update automatically as statuses change
- **Responsive Design:** Dashboard adapts to your screen size (Desktop/Tablet/Mobile)
- **Quick Access:** Tap your avatar to access your profile
- **Notifications:** Tap the bell icon to view all notifications
- **Manual Refresh:** Click the refresh button (desktop) to reload dashboard data

**Visual Guide:** The technician dashboard displays a personalized header with your name and role, followed by ticket statistics and a list of all tickets assigned to you. You can quickly see your workload and access individual tickets for details.

---

## Viewing Assigned Tickets

You can view all your assigned maintenance tickets in several ways:

### From Dashboard

1. **Ticket List**

   - Your dashboard shows all assigned tickets in a list
   - Scroll to see older tickets
   - Pull down to refresh (mobile)
   - Click refresh button (desktop)

2. **View Ticket Details**
   - Tap/click on any ticket in the list
   - You'll see the full ticket details page

### From Tickets List Page

1. **Access Tickets List**

   - Navigate to `/maintenance-tickets` (if available via menu)
   - Or access through the dashboard

2. **Filter Options**

   - Filter by status (Assigned, In Progress, Completed, On Hold, etc.)
   - Filter by priority (Low, Medium, High, Critical)
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
  - Assigned technician (you)
  - Villa/property information
  - Location details
  - Creation date and time
  - Last updated timestamp

- **Status History:**

  - Timeline of status changes
  - Who made each change (technician, admin)
  - When each change occurred

- **Comments and Updates:**

  - All comments from tenants, admins, and other technicians
  - Ability to add your own comments/notes
  - File attachments (photos, documents)

- **Actions Available:**
  - Update ticket status
  - Add comments/notes
  - View location details
  - View tenant information
  - Track progress in real-time

---

## Updating Ticket Status

As a technician, you can update the status of tickets assigned to you to track your work progress.

### Available Status Options

- **Assigned:** Ticket is assigned but work hasn't started
- **In Progress:** You've started working on the ticket
- **On Hold:** Work is temporarily paused (waiting for parts, tenant access, etc.)
- **Completed:** Work is finished and ticket is resolved

### How to Update Status

1. **From Ticket Detail Page**

   - Open the ticket you want to update
   - Look for the status section or status update button
   - Select the new status from the dropdown or button options
   - Click "Update Status" or "Save"
   - The system will update the status and notify relevant parties

2. **From Ticket List (Quick Actions)**

   - Some views may have quick action buttons
   - Click the status button next to a ticket
   - Select the new status
   - Confirm the update

### Status Update Best Practices

- **Start Work:** Change status to "In Progress" when you begin working on a ticket
- **Pause Work:** Use "On Hold" if you need to wait for parts, tenant access, or other dependencies
- **Complete Work:** Change to "Completed" only when the work is fully finished and verified
- **Add Notes:** Always add a comment when changing status to explain the change

**Note:** Status updates are tracked in the ticket history, so all changes are visible to admins and tenants.

---

## Adding Comments and Notes

Adding comments and notes helps communicate progress, issues, and updates to tenants and facility management.

### How to Add Comments

1. **From Ticket Detail Page**

   - Open the ticket you want to comment on
   - Scroll to the "Comments" or "Notes" section
   - Click "Add Comment" or "Add Note"
   - Type your comment in the text field
   - Optionally attach files or photos
   - Click "Post" or "Submit"

2. **Comment Best Practices**

   - **Be Clear:** Write clear, professional comments
   - **Be Specific:** Include details about what you did or found
   - **Be Timely:** Update comments as you work on the ticket
   - **Include Photos:** Attach photos to show progress or issues
   - **Status Updates:** Mention status changes in your comments

### Types of Comments

- **Progress Updates:** "Started work on the AC unit. Found that the filter needs replacement."
- **Status Changes:** "Work completed. Tenant confirmed the issue is resolved."
- **Questions:** "Need access to the villa. Please confirm best time to visit."
- **Issues Found:** "Discovered additional issue with the plumbing. May need additional parts."
- **Completion Notes:** "All work completed. Tested and verified. Tenant satisfied."

### File Attachments

- **Photos:** Take photos of the issue, work in progress, or completed work
- **Documents:** Attach relevant documents if needed
- **Before/After:** Include before and after photos when possible

---

## Notifications

The system sends notifications for important events related to your assigned tickets.

### Accessing Notifications

1. **Notification Bell**

   - Click/tap the bell icon in the dashboard header (if available)
   - A red dot indicates unread notifications
   - Number badge shows count of unread notifications

2. **Notification List Page**
   - View all notifications (read and unread)
   - Mark notifications as read
   - Filter by type or date

### Notification Types

You'll receive notifications for:

- **New Ticket Assignment:** When a new ticket is assigned to you
- **Status Updates:** When ticket status changes (if you're watching the ticket)
- **Comments:** When tenants or admins add comments to your assigned tickets
- **Priority Changes:** When ticket priority is updated
- **Ticket Reassignment:** If a ticket is reassigned to or from you
- **System Alerts:** Important system announcements

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
- View your email address
- Update contact details (phone number, etc.)
- View your technician role

**Security & Password:**

- Change your password
- View security settings
- Manage account security

**Account Details:**

- View your account information
- See your role (Technician)
- View account creation date
- View assigned tickets count (if available)

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Cannot Login

**Problem:** Login fails with error message

**Solutions:**

- Verify your email address is correct
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

#### 4. Cannot See Assigned Tickets

**Problem:** No tickets showing in dashboard

**Solutions:**

- Pull down to refresh (mobile) or click refresh button (desktop)
- Check if you have any tickets assigned to you
- Verify your user account is properly configured as a technician
- Contact your facility administrator if you believe tickets should be assigned

#### 5. Cannot Update Ticket Status

**Problem:** Unable to change ticket status

**Solutions:**

- Ensure the ticket is assigned to you
- Check that you have the necessary permissions
- Verify your internet connection
- Try refreshing the page
- Contact support if the issue persists

#### 6. Notifications Not Appearing

**Problem:** Not receiving notifications for ticket updates

**Solutions:**

- Check notification settings in your profile
- Ensure notifications are enabled in your browser/device settings
- Refresh the page to check for new notifications
- Clear browser cache
- Contact support if notifications are still not working

#### 7. Cannot Add Comments

**Problem:** Unable to add comments to tickets

**Solutions:**

- Ensure the ticket is assigned to you
- Check that all required fields are filled
- Verify your internet connection
- Try refreshing the page
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

### Ticket Management

1. **Status Updates:**

   - Update status promptly when you start, pause, or complete work
   - Always add a comment when changing status
   - Keep status current to help facility management track progress

2. **Communication:**

   - Add clear, professional comments
   - Update tickets regularly with progress notes
   - Respond to tenant questions promptly
   - Include photos when helpful

3. **Organization:**
   - Review your assigned tickets daily
   - Prioritize high-priority tickets
   - Complete tickets in a timely manner
   - Mark tickets as completed only when work is fully done

### Work Efficiency

1. **Time Management:**

   - Check your dashboard at the start of each day
   - Plan your work based on ticket priorities
   - Update tickets as you work on them
   - Complete tickets before moving to new ones

2. **Documentation:**

   - Take photos of issues and completed work
   - Write detailed comments about what you did
   - Note any additional issues discovered
   - Document parts or materials used

3. **Professional Communication:**
   - Use clear, professional language in comments
   - Be specific about work performed
   - Provide context and background information
   - Confirm completion with tenants when possible

### Quality Assurance

1. **Before Completing:**

   - Verify the issue is fully resolved
   - Test the repair or maintenance work
   - Confirm with tenant if possible
   - Add completion notes

2. **Follow-up:**
   - Check for any follow-up questions
   - Respond to comments from tenants or admins
   - Update tickets if additional work is needed

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
   - Displays email and password fields
   - Shows the "Forgot Password" and "Switch Site" options

### Technician Dashboard Screenshots

4. **Technician Dashboard Overview** (if available)
   - Personalized greeting and role badge
   - Ticket statistics bar
   - List of assigned tickets
   - Notification bell with unread count

---

## Appendix

### Glossary

- **Ticket:** A maintenance request or work order
- **Technician:** A user assigned to perform maintenance work (you)
- **Company Code:** A unique identifier for your facility/organization
- **Dashboard:** Your main workspace after logging in
- **Status:** Current state of a ticket (Assigned, In Progress, Completed, etc.)
- **Priority:** Importance level of a ticket (Low, Medium, High, Critical)
- **Villa:** A property or facility unit
- **Tenant:** A property occupant or resident who creates maintenance requests

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
