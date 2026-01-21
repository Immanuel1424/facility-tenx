# TENX Facility ERP - Admin User Manual

**Version:** 1.0  
**Date:** January 2025  
**Application:** TENX Facility ERP System

---

## Table of Contents

1. [Introduction](#introduction)
2. [System Access](#system-access)
3. [Login Process](#login-process)
4. [Admin Dashboard Overview](#admin-dashboard-overview)
5. [Navigation Menu](#navigation-menu)
6. [User Management](#user-management)
7. [Maintenance Tickets Management](#maintenance-tickets-management)
8. [Villa Management](#villa-management)
9. [Notifications](#notifications)
10. [Profile Management](#profile-management)
11. [Settings & Configuration](#settings--configuration)
12. [Troubleshooting](#troubleshooting)
13. [Best Practices](#best-practices)

---

## Introduction

Welcome to the **TENX Facility ERP System** - a comprehensive facility management platform designed to streamline operations, track maintenance requests, and manage facilities efficiently.

This manual provides step-by-step instructions for administrators to effectively use the system. As an admin user, you have full access to manage users, maintenance tickets, villas, system configurations, and oversee all facility operations.

### System Requirements

- **Web Browser:** Chrome, Firefox, Safari, or Edge (latest versions)
- **Screen Resolution:** Minimum 1280x720 (1920x1080 recommended)
- **Internet Connection:** Stable connection required

### Admin Credentials

For this manual, we'll use the following example credentials:

- **Email:** `admin@example.com`
- **Password:** `password123`
- **Company Code:** `ALOS`

**Note:** Your actual credentials will be provided by your system administrator. Contact them if you need assistance with login credentials.

---

## System Access

### Accessing the Application

1. Open your web browser
2. Navigate to the TENX application URL (provided by your system administrator)
3. The application will load the **Company Selection** screen

---

## Login Process

The login process consists of two steps:

### Step 1: Company Selection

1. **Locate the Company Code Field**

   - On the right side of the screen (desktop) or at the top (mobile), you'll see a white form card
   - Find the "Company Code" input field

2. **Enter Company Code**

   - Type your company code: `ALOS` (or your organization's company code)
   - The field accepts alphanumeric characters (not UUID format)
   - Company codes are typically short, memorable codes provided by your organization

3. **Continue**
   - Click the orange "Continue" button or press Enter
   - The system validates the company code
   - If valid, you'll be redirected to the Login page

![Company Selection Screen](screenshots/01-company-selection.png)

**Note:** If you enter an invalid company code, you'll see an error message: "Invalid company code. Please check and try again."

---

### Step 2: User Login

1. **Enter Credentials**

   - **Email Field:** Enter your email address (e.g., `admin@example.com`)
     - **Important:** Admins use **email address** for login
     - Your email is provided by your system administrator
   - **Password Field:** Enter your password
     - Password field has a visibility toggle (eye icon) to show/hide the password

2. **Login**
   - Click the orange "Login" button
   - The system validates your credentials
   - Upon successful authentication, you'll be redirected to the Admin Dashboard

![Login Screen](screenshots/03-login-page.png)

**Additional Options:**

- **Forgot Password?** - Click the link below the password field to reset your password
- **Switch Site** - Click the "SWITCH SITE" button to change your company code

**Important Notes:**

- Email and password are case-sensitive
- Make sure you're using the correct company code for your organization
- If you've forgotten your password, use the "Forgot Password?" link to reset it

---

## Admin Dashboard Overview

After successful login, you'll land on the **Admin Dashboard**. This is your central hub for monitoring and managing all facility operations.

![Admin Dashboard](screenshots/04-admin-dashboard.png)

### Dashboard Components

The Admin Dashboard displays:

1. **Header Section**

   - Welcome message: "Welcome back, [Your Name]"
   - Subtitle: "Actionable insights and analytics for your maintenance operations"
   - Refresh icon button (top right) to manually reload data
   - Notification bell icon (top right) for system notifications
   - Period selector (Daily, Weekly, Monthly, Yearly) to filter data

2. **Key Metrics Section**

   The dashboard shows key metric cards:

   - **TOTAL TICKETS:** Displays the count of all-time tickets with a document icon
   - **NEW REQUESTS:** Shows tickets awaiting action with a refresh/circular arrow icon
   - **IN PROGRESS:** Displays currently active tickets with an orange play/triangle icon
   - **COMPLETED:** Shows successfully closed tickets with a green checkmark icon
   - **ON HOLD:** Displays paused tickets with a pause icon
   - Additional status metrics as applicable

3. **Recent Activity Section**

   - Lists the most recent ticket activities
   - Each activity shows:
     - Ticket ID (e.g., TKT-2026-0004)
     - Creator name
     - Priority level
     - Ticket title/description
     - Villa number
     - Time elapsed (e.g., "1d ago")
   - "View All" link to see complete activity history

4. **Current Status & Trends Section**

   - **Status Distribution Chart:** Visual representation of ticket status distribution
   - **Priority Distribution Chart:** Visual representation of ticket priority distribution
   - Additional analytics charts for trends and insights

5. **Villa & Technician Insights** (when available)

   - Villa Distribution Chart
   - Technician Performance Metrics
   - Additional analytics and predictions

### Dashboard Features

- **Period Selection:** Filter data by Daily, Weekly, Monthly, or Yearly periods
- **Refresh Button:** Manually refresh dashboard data from the header
- **Responsive Design:** Dashboard adapts to your screen size (Desktop/Tablet/Mobile)
- **Real-time Updates:** Metrics update automatically as tickets are created or modified
- **Analytics:** Comprehensive analytics and insights for decision-making

**Visual Guide:** The admin dashboard displays a comprehensive overview with key metrics cards at the top, followed by analytics charts and data visualizations below. The left sidebar provides navigation to all major sections.

---

## Navigation Menu

The left sidebar provides quick access to all major sections. The sidebar is prominently displayed on the left side of the screen with a dark orange background and contains navigation items with icons.

![Navigation Sidebar](screenshots/10-navigation-sidebar-detail.png)

**Visual Guide:** The navigation sidebar includes:

- **Top Section:**

  - TENX building icon
  - "TENX" brand name
  - "Facility ERP" subtitle

- **Main Navigation Menu:**

  - Each menu item has an icon and text label
  - Active menu item is highlighted with a lighter orange background
  - Menu items include:
    1. **Dashboard** - Grid icon (default active after login)
    2. **All Tickets** - Document icon
    3. **Users** - Two-person icon
    4. **Villas** - House icon
    5. **Settings** - Gear icon

- **Bottom Section (User Profile):**
  - Circular user avatar with initials (e.g., "AE")
  - User's full name (e.g., "Admin User")
  - Role badge (e.g., "ADMIN" in light orange)
  - "Sign Out" button with arrow icon

### Main Menu Items

1. **Dashboard** (`/dashboard`)

   - Overview of all system metrics and analytics
   - Default landing page after login
   - Displays key performance indicators and recent activity

2. **All Tickets** (`/maintenance-tickets`)

   - View and manage all maintenance tickets
   - Filter by status, priority, and villa number
   - Create new tickets
   - View ticket details
   - Assign technicians
   - Update ticket status

3. **Users** (`/iam/users`)

   - Manage system users
   - Create, view, and edit user accounts
   - Assign roles and permissions
   - Activate/deactivate users

4. **Villas** (`/villas`)

   - Manage villa/property listings
   - Create, view, and edit villa information
   - Search and filter villas
   - View villa maintenance history

5. **Settings** (`/settings`)
   - System configuration
   - Personal preferences
   - Security settings
   - Notification preferences
   - Email template management

### User Profile Section

At the bottom of the sidebar, you'll see:

- **User Avatar:** Circular icon with your initials
- **Name:** Your full name as displayed in the system
- **Role Badge:** Your current role (e.g., ADMIN, SUPERVISOR)
- **Sign Out Button:** Logout option to securely end your session

---

## User Management

To access User Management:

1. Click **"Users"** in the left sidebar
2. You'll be taken to the User Management page

![Users Management Page](screenshots/06-users-management.png)

**Visual Guide:** The User Management page displays a list/table of users with columns for name, email, role, status, and actions. A "Create User" button is typically located at the top right.

**Note:** If you encounter a network error, you'll see an error message: "Error: Exception: No internet connection. Please check your network settings." Click the "Retry" button to reload the page.

### Features Available:

- **View Users:** List of all system users

  - User name
  - Email address
  - Role(s) assigned
  - Status (Active/Inactive)
  - Last login information
  - Actions menu

- **Create User:** Add new users to the system

  - Access via "Create User" or "+" button
  - Fill in user details form
  - Assign roles and permissions

- **Edit User:** Modify user information

  - Click on user or use actions menu
  - Update user details
  - Modify role assignments
  - Change user status

- **User Details:** View detailed user information

  - Full user profile
  - Activity history
  - Permission details
  - Assigned tickets (if applicable)

- **Role Assignment:** Assign roles and permissions to users
  - Select from available roles (Admin, Technician, Tenant, etc.)
  - Customize permissions if allowed
  - Manage role-based access control

### Creating a New User:

1. Click the **"Create User"** or **"+"** button from the User Management page
2. Fill in the required information in the user creation form:
   - **Email:** User's email address (required, must be unique)
   - **Name:** User's full name (required)
   - **Phone Number:** Contact number (optional)
   - **Role(s):** Select one or more roles from available options
   - **Status:** Set user as Active or Inactive
   - **Password:** Set initial password (user may be required to change on first login)
   - Other relevant details as required
3. Review all information
4. Click **"Save"** or **"Create"** to create the user

**Note:** Ensure you have the necessary permissions to create users. Some fields may be required based on your organization's configuration.

### Editing a User:

1. Click on the user from the list or use the actions menu
2. Select "Edit" or click on the user row
3. Update the desired information:
   - Personal information (name, email, phone)
   - Role assignments
   - Status (Active/Inactive)
   - Permissions
4. Click **"Save"** to apply changes

### Managing User Roles:

- **Assign Roles:** Select roles from the available list
- **Remove Roles:** Uncheck roles to remove them
- **Role Types:**
  - **Admin:** Full system access
  - **Technician:** Can view and update assigned tickets
  - **Tenant:** Can create and view their own tickets
  - **Supervisor:** Can oversee technicians and tickets

---

## Maintenance Tickets Management

The maintenance ticket system is central to facility management operations.

### Accessing Tickets

1. Click **"All Tickets"** in the left sidebar
2. You'll see a list of all maintenance tickets in a table or card view

![All Tickets List](screenshots/05-all-tickets-list.png)

**Visual Guide:** The Tickets page shows a comprehensive list view with filters at the top. Each ticket displays key information such as ticket ID, title, status, priority, assigned technician, villa number, and creation date.

**Note:** If you encounter a network error, you'll see an error message with a "Retry" button. Click "Retry" to reload the tickets list.

### Ticket List Features:

- **Header:**

  - Page title: "Maintenance Tickets"
  - Back arrow to return to previous page
  - Create ticket button (typically a "+" icon or "Create Ticket" button)

- **Filters:**

  - Status (Open, In Progress, Completed, On Hold, etc.)
  - Priority (Low, Medium, High, Critical)
  - Villa Number
  - Assigned Technician
  - Date Range
  - Search by ticket ID or description

- **View Options:**

  - List view (default)
  - Card view (on mobile/tablet)
  - Table view (on desktop)
  - Sortable columns

- **Ticket Information Displayed:**

  - Ticket ID (e.g., TKT-2026-0004)
  - Title/Description
  - Status badge with color coding
  - Priority indicator
  - Assigned technician name
  - Villa number
  - Creation date and time
  - Last updated timestamp

- **Actions Available:**
  - View ticket details (click on ticket)
  - Edit ticket
  - Assign/reassign technician
  - Update status
  - Change priority
  - Add comments
  - Attach files
  - Delete ticket (if permitted)

### Creating a Ticket:

![Create Ticket Page](screenshots/09-create-ticket-page.png)

1. Click **"Create Ticket"** or **"+"** button from the All Tickets page
2. You'll be taken to the "New Ticket" form page
3. Fill in the ticket information:

   **Describe the Issue Section:**

   - **Ticket Type:** Select from dropdown (e.g., Maintenance, Repair, Inspection)
   - **Title:** Enter a brief, descriptive title for the ticket
   - **Description:** Provide detailed information about the issue
     - Use the formatting toolbar (hamburger menu icon) for text formatting if available

   **Location Section:**

   - **Select Site:** Choose the site/location from dropdown
   - **Select Space:** Choose the specific space/villa from dropdown

   **Additional Options:**

   - **Priority:** Set priority level (Low, Medium, High, Critical)
   - **Assign Technician:** Optionally assign a technician immediately

4. Review all information
5. Click **"Submit Request"** button to create the ticket

**Note:** All fields marked with an asterisk (\*) are required. Ensure you provide complete information for efficient ticket processing.

### Ticket Details:

![Ticket Detail Page](screenshots/11-ticket-detail-page.png)

Clicking on a ticket from the list opens the detailed view showing:

- **Header:**

  - Ticket ID and title
  - Back arrow to return to list
  - Refresh button
  - Action menu (if available)

- **Ticket Information:**

  - Full ticket description
  - Current status with status badge
  - Priority level
  - Assigned technician (if assigned)
  - Villa/property information
  - Creation date and time
  - Last updated timestamp

- **Status History:**

  - Timeline of status changes
  - Who made each change
  - When each change occurred

- **Comments and Updates:**

  - All comments and updates from users
  - Ability to add new comments
  - File attachments if any

- **Actions Available:**
  - Edit ticket information
  - Change status
  - Assign/reassign technician
  - Change priority
  - Add comments
  - Upload attachments
  - View related tickets (if any)
  - Delete ticket (if permitted)

**Note:** If you see a permission error, ensure your user role has the necessary permissions to view ticket details. Contact your system administrator if needed.

### Assigning Technicians:

1. **From Ticket Detail Page:**

   - Open the ticket you want to assign
   - Look for "Assign Technician" section or button
   - Select a technician from the dropdown
   - Click "Assign" or "Save"
   - The technician will be notified

2. **From Ticket List (Quick Assign):**
   - Some views may have quick assign options
   - Click the assign button next to a ticket
   - Select technician from dropdown
   - Confirm assignment

### Updating Ticket Status:

1. Open the ticket you want to update
2. Look for the status section or status update button
3. Select the new status from the dropdown
4. Optionally add a comment explaining the status change
5. Click "Update Status" or "Save"

### Changing Ticket Priority:

1. Open the ticket
2. Find the priority section
3. Select new priority level
4. Save changes

---

## Villa Management

Villas represent the properties/facilities managed in the system.

### Accessing Villas

1. Click **"Villas"** in the left sidebar
2. You'll be taken to the Villas Management page

![Villas Management Page](screenshots/07-villas-management.png)

**Visual Guide:** The Villas page displays a list of all villas/properties with search and filter capabilities.

**Note:** If you encounter an error, you may see: "Error: Unexpected response format: String. Expected List or { data: [] }". Click the "Retry" button to reload the page. If the error persists, contact your system administrator.

### Villa List Features:

- **Header:**

  - Page title: "Villas"
  - Back arrow to return to previous page
  - Create villa button (typically a "+" icon or "Create Villa" button)

- **Search Functionality:**

  - Search by villa number
  - Search by address
  - Search by other attributes (type, status, etc.)

- **Filters:**

  - Filter by villa type
  - Filter by status (Active, Inactive, etc.)
  - Filter by location/city
  - Filter by other custom attributes

- **Villa Information Displayed:**

  - Villa number
  - Address
  - Type
  - Status
  - Associated tickets count
  - Last maintenance date (if available)

- **View/Edit Options:**
  - Click on a villa to view details
  - Edit villa information
  - View associated tickets
  - View maintenance history

### Creating a Villa:

1. Click **"Create Villa"** or **"+"** button from the Villas page
2. Fill in the villa information in the creation form:
   - **Villa Number:** Unique identifier for the villa (required)
   - **Address:** Full address of the villa (required)
   - **Type:** Select villa type from dropdown (e.g., Apartment, Villa, Unit)
   - **Status:** Set status (Active, Inactive, Under Maintenance, etc.)
   - **City/Location:** Select or enter city
   - **Other Details:** Additional information as required
3. Review all information
4. Click **"Save"** or **"Create"** to create the villa

**Note:** Ensure all required fields are filled. Villa numbers must be unique within your organization.

### Editing a Villa:

1. Click on the villa from the list
2. Select "Edit" or use the actions menu
3. Update the desired information
4. Click "Save" to apply changes

### Viewing Villa Details:

- **Villa Information:** Full details about the villa
- **Associated Tickets:** All tickets related to this villa
- **Maintenance History:** Historical maintenance records
- **Tenant Information:** Current tenant details (if applicable)

---

## Notifications

The system sends notifications for important events related to system operations and tickets.

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

- **New Ticket Created:** When a new maintenance ticket is created
- **Status Updates:** When ticket status changes
- **Technician Assignment:** When technicians are assigned or reassigned
- **Priority Changes:** When ticket priority is updated
- **User Management:** When users are created, updated, or deactivated
- **System Alerts:** Important system announcements and alerts
- **Comments:** When comments are added to tickets

### Managing Notifications

- **Mark as Read:** Tap/click on a notification to mark it as read
- **View Related Item:** Tap/click on a notification to view the related ticket, user, or item
- **Clear All:** Option to mark all notifications as read (if available)
- **Filter:** Filter notifications by type, date, or status

---

## Profile Management

You can manage your profile information and account settings.

### Accessing Your Profile

1. **From Dashboard**

   - Click/tap your avatar (circular icon with your initial) in the sidebar
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
- View your admin role

**Security & Password:**

- Change your password
- View security settings
- Manage account security
- View active sessions (if available)

**Account Details:**

- View your account information
- See your role (Admin)
- View permissions
- View account creation date
- View last login information

---

## Settings & Configuration

Access system settings and personal preferences:

1. Click **"Settings"** in the left sidebar
2. You'll be taken to the Settings page

![Settings Page](screenshots/08-settings-page.png)

The Settings page is organized into three main sections:

### 1. Profile Settings

This section allows you to manage your personal account information.

**Personal Information:**

- **Icon:** Person icon
- **Title:** "Personal Information"
- **Description:** "Update your name, email, and contact details"
- **Action:** Click to navigate to personal information editing page
  - Update your name
  - Change email address
  - Update contact details
  - Modify profile picture (if available)

**Security & Password:**

- **Icon:** Padlock icon
- **Title:** "Security & Password"
- **Description:** "Change password and manage security settings"
- **Action:** Click to navigate to security settings
  - Change password
  - Enable/disable two-factor authentication (if available)
  - Manage security questions
  - View active sessions

**Account Details:**

- **Icon:** Building with gear icon
- **Title:** "Account Details"
- **Description:** "View your account information and roles"
- **Current Role Badge:** Displays your current role (e.g., "Admin" in orange)
- **Action:** Click to view detailed account information
  - View account information
  - See assigned roles
  - View permissions
  - Account creation date

### 2. Notifications Settings

This section allows you to control how and when you receive notifications.

All notification settings have toggle switches on the right side. Toggle ON (orange) to enable, OFF (grey) to disable.

**Push Notifications:**

- **Icon:** Bell icon
- **Title:** "Push Notifications"
- **Description:** "Receive push notifications on your device"
- **Toggle:** Enable/disable push notifications

**Email Notifications:**

- **Icon:** Envelope icon
- **Title:** "Email Notifications"
- **Description:** "Receive notifications via email"
- **Toggle:** Enable/disable email notifications

**Ticket Updates:**

- **Icon:** Document with pen icon
- **Title:** "Ticket Updates"
- **Description:** "Get notified about ticket status changes"
- **Toggle:** Enable/disable ticket update notifications

**System Alerts:**

- **Icon:** Warning triangle icon
- **Title:** "System Alerts"
- **Description:** "Receive important system alerts and announcements"
- **Toggle:** Enable/disable system alerts

### 3. Email Templates

This section allows you to manage email notification templates.

**Manage Email Templates:**

- **Icon:** Pencil icon
- **Title:** "Manage Email Templates"
- **Description:** "View and edit all email notification templates"
- **Action:** Click to navigate to email template management
  - View all email templates
  - Edit template content
  - Customize email formats
  - Preview templates

### Additional Settings (if available):

- **Regional Settings:** Set timezone, date format, currency
- **Language Preferences:** Select preferred language
- **Display Preferences:** Theme, font size, layout options
- **Data Export:** Export your data
- **Account Deletion:** Delete account (if permitted)

**Note:** Some settings may require specific permissions. Contact your system administrator if you need access to certain configuration options.

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
- Contact system administrator if issue persists

#### 2. Company Code Not Recognized

**Problem:** "Invalid company code" error

**Solutions:**

- Double-check the company code spelling (case-insensitive)
- Contact your system administrator to verify the company code
- Ensure you're using the correct company code for your organization

#### 3. Dashboard Not Loading

**Problem:** Dashboard shows loading indicator or error

**Solutions:**

- Check your internet connection
- Refresh the page (F5 or Ctrl+R / Cmd+R)
- Clear browser cache
- Try logging out and logging back in
- Contact support if the issue persists

#### 4. Missing Menu Items

**Problem:** Some menu items are not visible

**Solutions:**

- Verify your user role has the necessary permissions
- Contact your system administrator to grant required permissions
- Some features may be role-specific

#### 5. Cannot Create or Edit Users

**Problem:** Unable to create or modify users

**Solutions:**

- Verify you have user management permissions
- Check that all required fields are filled
- Ensure email addresses are unique
- Try refreshing the page
- Contact support if the issue persists

#### 6. Cannot Assign Technicians

**Problem:** Unable to assign technicians to tickets

**Solutions:**

- Verify the technician user exists and is active
- Check that you have ticket management permissions
- Ensure the ticket is in an assignable status
- Try refreshing the page
- Contact support if the issue persists

#### 7. Slow Performance

**Problem:** Application is slow or unresponsive

**Solutions:**

- Check your internet connection speed
- Close other browser tabs/applications
- Clear browser cache
- Try a different browser
- Check if there are system-wide issues (contact administrator)

#### 8. Notifications Not Appearing

**Problem:** Not receiving notifications

**Solutions:**

- Check notification settings in Settings page
- Ensure notifications are enabled in your browser/device settings
- Refresh the page to check for new notifications
- Clear browser cache
- Contact support if notifications are still not working

---

## Best Practices

### Security

1. **Password Management:**

   - Use strong, unique passwords
   - Change passwords regularly
   - Never share your credentials
   - Log out when finished (especially on shared computers)

2. **Session Management:**

   - Log out properly when done
   - Don't leave your session open on unattended computers
   - Use secure networks when accessing the system

3. **Access Control:**
   - Regularly review user permissions
   - Deactivate unused accounts
   - Assign appropriate roles to users
   - Monitor user activity

### Data Management

1. **Regular Updates:**

   - Update ticket statuses promptly
   - Keep user information current
   - Maintain accurate villa/property data
   - Review and update system settings regularly

2. **Documentation:**

   - Add clear descriptions when creating tickets
   - Use comments to track progress
   - Attach relevant documents and images
   - Document important decisions and changes

3. **Organization:**
   - Use appropriate priorities for tickets
   - Assign tickets to correct technicians
   - Utilize filters and search effectively
   - Keep villa information up to date

### User Management

1. **User Creation:**

   - Verify user information before creating accounts
   - Assign appropriate roles based on job function
   - Set strong initial passwords
   - Provide users with login credentials securely

2. **Role Assignment:**

   - Assign roles based on job responsibilities
   - Review role assignments regularly
   - Remove unnecessary permissions
   - Follow principle of least privilege

3. **Account Maintenance:**
   - Deactivate accounts for users who no longer need access
   - Update user information when it changes
   - Monitor user activity for security
   - Review and clean up inactive accounts

### Ticket Management

1. **Ticket Creation:**

   - Provide clear, detailed descriptions
   - Set appropriate priority levels
   - Assign to correct technicians
   - Include all relevant information

2. **Ticket Assignment:**

   - Assign tickets based on technician expertise
   - Consider technician workload
   - Reassign when necessary
   - Communicate assignments clearly

3. **Ticket Monitoring:**
   - Regularly review ticket status
   - Follow up on overdue tickets
   - Ensure tickets are completed properly
   - Close tickets only when work is verified

### System Administration

1. **Regular Maintenance:**

   - Review system performance regularly
   - Monitor dashboard metrics
   - Check for system alerts
   - Update system settings as needed

2. **Communication:**

   - Keep users informed of system changes
   - Respond to user questions promptly
   - Provide training when needed
   - Document procedures and policies

3. **Backup and Recovery:**
   - Ensure data is backed up regularly
   - Test recovery procedures
   - Document backup schedules
   - Plan for disaster recovery

---

## Keyboard Shortcuts

- **Tab:** Navigate between form fields
- **Enter:** Submit forms or confirm actions
- **Escape:** Close dialogs or cancel actions
- **Ctrl+F / Cmd+F:** Search (on pages with search functionality)
- **F5 / Ctrl+R / Cmd+R:** Refresh page
- **Ctrl+S / Cmd+S:** Save (on forms, if available)

---

## Support & Contact

For technical support or questions:

- **System Administrator:** Contact your system administrator for account issues
- **In-App:** Use the help/support feature (if available)
- **Documentation:** Refer to additional system documentation

---

## Screenshots Reference

This section provides an overview of the key screenshots available for reference:

### Login Flow Screenshots

1. **Company Selection Screen** (`screenshots/01-company-selection.png`)

   - Shows the initial company code entry screen
   - Displays the promotional content on the left and form on the right
   - Demonstrates the modern, clean UI design

2. **Company Selection with Form** (`screenshots/02-company-selection-filled.png`)

   - Shows the company code input field
   - Displays the validation and form structure
   - Illustrates the "Continue" button

3. **Login Screen** (`screenshots/03-login-page.png`)
   - Shows the login form after company selection
   - Displays email and password fields
   - Shows the "Forgot Password" and "Switch Site" options

### Admin Dashboard Screenshots

4. **Admin Dashboard Overview** (`screenshots/04-admin-dashboard.png`)

   - Complete dashboard view with key metrics
   - Recent activity feed
   - Status and priority distribution charts
   - Navigation sidebar visible on the left

5. **Navigation Sidebar Detail** (`screenshots/10-navigation-sidebar-detail.png`)
   - Full sidebar navigation menu
   - User profile section at bottom
   - Active menu item highlighting
   - Role badge display

### Maintenance Tickets Screenshots

6. **All Tickets List Page** (`screenshots/05-all-tickets-list.png`)

   - List view of all maintenance tickets
   - Error handling display (if network issues occur)
   - Retry functionality
   - Header with back navigation

7. **Create Ticket Page** (`screenshots/09-create-ticket-page.png`)

   - New ticket creation form
   - "Describe the Issue" section with ticket type, title, and description fields
   - "Location" section with site and space selection
   - Submit Request button

8. **Ticket Detail Page** (`screenshots/11-ticket-detail-page.png`)
   - Individual ticket details view
   - Error handling for permission issues
   - Header with back and refresh buttons
   - Retry functionality

### User Management Screenshots

9. **Users Management Page** (`screenshots/06-users-management.png`)
   - User list interface
   - Error handling display
   - Header with page title
   - Retry button for network errors

### Villa Management Screenshots

10. **Villas Management Page** (`screenshots/07-villas-management.png`)
    - Villa listing interface
    - Error handling for API response issues
    - Header navigation
    - Retry functionality

### Settings Screenshots

11. **Settings Page** (`screenshots/08-settings-page.png`)
    - Complete settings interface
    - Three main sections: Profile, Notifications, Email Templates
    - Toggle switches for notification preferences
    - Navigation options for each setting category

**Note:** All screenshots have been captured from the production environment and represent the current UI state. Some screenshots may show error states which are part of normal error handling in the application.

---

## Appendix

### Glossary

- **Ticket:** A maintenance request or work order
- **Villa:** A property or facility unit in the system
- **Technician:** A user assigned to perform maintenance work
- **Tenant:** A property occupant or resident
- **Admin:** Administrator with full system access
- **Role:** User role defining permissions and access level
- **Permission:** Specific access right to perform an action on a resource

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

For the most up-to-date information, please refer to the online documentation or contact your system administrator.
