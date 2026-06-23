<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <title>UniVents - My Profile</title>
        <link rel="stylesheet" href="style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            .profile-page {
                min-height: 80vh;
                padding: 40px 20px;
                background: #f4f7f6;
            }
            .profile-header {
                text-align: center;
                margin-bottom: 30px;
            }
            .profile-header h2 {
                color: #800000;
                font-size: 28px;
                margin-bottom: 5px;
            }
            .profile-header p {
                color: #666;
                font-size: 15px;
            }
            .profile-card {
                max-width: 800px;
                margin: 0 auto;
                background-color: white;
                border-radius: 12px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.08);
                overflow: hidden;
            }
            .card-header {
                background: linear-gradient(135deg, #800000, #b30000);
                color: white;
                padding: 20px;
                display: flex;
                align-items: center;
                gap: 15px;
            }
            .profile-avatar {
                width: 60px;
                height: 60px;
                background-color: white;
                color: #800000;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 30px;
            }
            .card-header h3 {
                margin: 0;
                font-size: 22px;
            }
            .card-header span {
                opacity: 0.8;
                font-size: 14px;
            }
            .card-body {
                padding: 30px;
            }
            .form-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            .form-group {
                margin-bottom: 5px;
            }
            .full-width {
                grid-column: 1 / -1;
            }
            .form-group label {
                font-weight: 600;
                color: #444;
                display: block;
                margin-bottom: 8px;
                font-size: 14px;
            }
            
            /* Styles for Static Information (Non-editable) */
            .static-value {
                padding: 12px 15px;
                background-color: #f8f9fa;
                border: 1px dashed #ccc;
                border-radius: 8px;
                color: #555;
                font-size: 15px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .static-value i {
                color: #800000;
                width: 20px;
                text-align: center;
            }

            /* Styles for Editable Inputs */
            .input-with-icon {
                position: relative;
            }
            .input-with-icon .left-icon {
                position: absolute;
                left: 12px;
                top: 50%;
                transform: translateY(-50%);
                color: #888;
            }
            .input-with-icon .right-icon {
                position: absolute;
                right: 12px;
                top: 50%;
                transform: translateY(-50%);
                color: #888;
                cursor: pointer;
                padding: 5px; /* Easy to click */
            }
            .input-with-icon .right-icon:hover {
                color: #800000;
            }
            .form-group input {
                width: 100%;
                padding: 12px 40px 12px 35px; /* Add padding for left and right icons */
                border: 1px solid #ddd;
                border-radius: 8px;
                box-sizing: border-box;
                font-family: inherit;
                transition: border-color 0.3s;
                background-color: #fff;
            }
            .form-group input:focus {
                border-color: #800000;
                outline: none;
                box-shadow: 0 0 5px rgba(128,0,0,0.2);
            }
            
            .security-section {
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px dashed #ccc;
            }
            .security-title {
                color: #800000;
                font-size: 18px;
                margin-bottom: 20px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .btn-save {
                background-color: #800000;
                color: white;
                padding: 14px 20px;
                border: none;
                border-radius: 8px;
                font-size: 16px;
                font-weight: bold;
                cursor: pointer;
                width: 100%;
                margin-top: 20px;
                transition: background 0.3s, transform 0.1s;
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 10px;
            }
            .btn-save:hover {
                background-color: #5c0000;
            }
            .notice-alert {
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 20px;
                text-align: center;
                font-weight: bold;
                max-width: 800px;
                margin: 0 auto 20px auto;
            }
            .notice-success {
                background-color: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }
            .notice-error {
                background-color: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }
            
            @media (max-width: 600px) {
                .form-grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="profile-page">
            <div class="profile-header">
                <h2>Manage Profile</h2>
                <p>Update your personal information and security settings</p>
            </div>

            <c:if test="${param.msg == 'success'}">
                <div class="notice-alert notice-success">
                    <i class="fas fa-check-circle"></i> Profile updated successfully!
                </div>
            </c:if>
            <c:if test="${param.error == 'failed'}">
                <div class="notice-alert notice-error">
                    <i class="fas fa-exclamation-triangle"></i> Failed to update profile. Please try again.
                </div>
            </c:if>
            <c:if test="${param.error == 'wrongPassword'}">
                <div class="notice-alert notice-error">
                    <i class="fas fa-lock"></i> Security Error: Your Current Password was incorrect!
                </div>
            </c:if>

            <div class="profile-card">
                <div class="card-header">
                    <div class="profile-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div>
                        <h3>${profileData[5]}</h3>
                        <span>${sessionScope.userRole}</span>
                    </div>
                </div>
                
                <div class="card-body">
                    <div class="form-grid" style="margin-bottom: 30px;">
                        <div class="form-group full-width">
                            <label>Email Address / Username</label>
                            <div class="static-value">
                                <i class="fas fa-envelope"></i> ${profileData[0]}
                            </div>
                        </div>

                        <c:if test="${sessionScope.userRole != 'ADVISOR'}">
                            <div class="form-group">
                                <label>Program / Position</label>
                                <div class="static-value">
                                    <i class="fas fa-graduation-cap"></i> ${profileData[2]}
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Year of Study</label>
                                <div class="static-value">
                                    <i class="fas fa-calendar-alt"></i> ${profileData[3]}
                                </div>
                            </div>
                        </c:if>
                    </div>

                    <form action="ProfileServlet" method="POST">
                        <div class="form-grid">
                            <div class="form-group full-width">
                                <label>Phone Number</label>
                                <div class="input-with-icon">
                                    <i class="fas fa-phone-alt left-icon"></i>
                                    <input type="text" name="phoneNo" value="${profileData[1]}" required>
                                </div>
                            </div>
                        </div>

                        <div class="security-section">
                            <h3 class="security-title"><i class="fas fa-shield-alt"></i> Security & Password</h3>
                            
                            <div class="form-grid">
                                <div class="form-group">
                                    <label>Current Password <span style="color:red">*</span></label>
                                    <div class="input-with-icon">
                                        <i class="fas fa-key left-icon"></i>
                                        <input type="password" name="currentPassword" id="currentPwdField" placeholder="Required to save changes" required>
                                        <i class="fas fa-eye right-icon" onclick="toggleVisibility('currentPwdField', this)" title="Show/Hide Password"></i>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label>New Password</label>
                                    <div class="input-with-icon">
                                        <i class="fas fa-lock left-icon"></i>
                                        <input type="password" name="newPassword" id="newPwdField" placeholder="Leave blank to keep current">
                                        <i class="fas fa-eye right-icon" onclick="toggleVisibility('newPwdField', this)" title="Show/Hide Password"></i>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="btn-save">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <script>
            function toggleVisibility(fieldId, iconElement) {
                var field = document.getElementById(fieldId);
                if (field.type === "password") {
                    field.type = "text";
                    // Change icon to 'eye-slash' (hidden)
                    iconElement.classList.remove("fa-eye");
                    iconElement.classList.add("fa-eye-slash");
                } else {
                    field.type = "password";
                    // Revert icon to 'eye' (visible)
                    iconElement.classList.remove("fa-eye-slash");
                    iconElement.classList.add("fa-eye");
                }
            }
        </script>

        <jsp:include page="footer.jsp" />
    </body>
</html>