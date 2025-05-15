import os

def create_directory(path):
    os.makedirs(path, exist_ok=True)
    print(f"Created directory: {path}")

def create_file(path, content=""):
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created file: {path}")

def create_project_structure():
    # Root directory
    create_directory("lib")
    
    # Main files
    create_file("lib/app.dart")
    create_file("lib/main.dart")
    
    # Core directory
    core_dirs = [
        "core/constants",
        "core/error",
        "core/utils",
        "core/widgets"
    ]
    
    for dir_path in core_dirs:
        create_directory(f"lib/{dir_path}")
    
    # Core files
    core_files = {
        "core/constants/api_constants.dart": "",
        "core/constants/app_constants.dart": "",
        "core/constants/theme_constants.dart": "",
        "core/error/app_error.dart": "",
        "core/error/error_handler.dart": "",
        "core/utils/file_utils.dart": "",
        "core/utils/format_utils.dart": "",
        "core/utils/permissions_helper.dart": "",
        "core/widgets/app_button.dart": "",
        "core/widgets/app_loading.dart": "",
        "core/widgets/error_dialog.dart": ""
    }
    
    for file_path, content in core_files.items():
        create_file(f"lib/{file_path}", content)
    
    # Data directory
    data_dirs = [
        "data/api/interceptors",
        "data/models",
        "data/repositories",
        "data/services"
    ]
    
    for dir_path in data_dirs:
        create_directory(f"lib/{dir_path}")
    
    # Data files
    data_files = {
        "data/api/api_client.dart": "# Base API client",
        "data/api/api_service.dart": "# API service interfaces",
        "data/api/interceptors/auth_interceptor.dart": "",
        "data/models/api_response.dart": "",
        "data/models/conversion_result.dart": "",
        "data/models/merge_result.dart": "",
        "data/models/pdf_file.dart": "",
        "data/models/repair_result.dart": "",
        "data/models/sign_result.dart": "",
        "data/models/split_result.dart": "",
        "data/models/user.dart": "",
        "data/repositories/auth_repository.dart": "",
        "data/repositories/pdf_repository.dart": "",
        "data/repositories/user_repository.dart": "",
        "data/services/file_service.dart": "# File handling service",
        "data/services/storage_service.dart": "# Local storage service"
    }
    
    for file_path, content in data_files.items():
        create_file(f"lib/{file_path}", content)
    
    # Presentation directory
    presentation_dirs = [
        "presentation/router",
        "presentation/screens/auth",
        "presentation/screens/compress",
        "presentation/screens/convert",
        "presentation/screens/home",
        "presentation/screens/merge",
        "presentation/screens/protect",
        "presentation/screens/repair",
        "presentation/screens/result",
        "presentation/screens/sign",
        "presentation/screens/split",
        "presentation/screens/user",
        "presentation/widgets/common",
        "presentation/widgets/compress",
        "presentation/widgets/convert",
        "presentation/widgets/merge",
        "presentation/widgets/result",
        "presentation/widgets/sign",
        "presentation/widgets/split"
    ]
    
    for dir_path in presentation_dirs:
        create_directory(f"lib/{dir_path}")
    
    # Presentation files
    presentation_files = {
        "presentation/router/app_router.dart": "# GoRouter configuration",
        "presentation/router/route_names.dart": "# Route name constants",
        "presentation/screens/auth/login_screen.dart": "",
        "presentation/screens/auth/register_screen.dart": "",
        "presentation/screens/compress/compress_screen.dart": "",
        "presentation/screens/convert/convert_screen.dart": "",
        "presentation/screens/home/home_screen.dart": "",
        "presentation/screens/merge/merge_screen.dart": "",
        "presentation/screens/protect/protect_screen.dart": "",
        "presentation/screens/repair/repair_screen.dart": "",
        "presentation/screens/result/result_screen.dart": "",
        "presentation/screens/sign/sign_screen.dart": "",
        "presentation/screens/split/split_screen.dart": "",
        "presentation/screens/user/profile_screen.dart": "",
        "presentation/screens/user/settings_screen.dart": "",
        "presentation/widgets/common/file_picker_button.dart": "",
        "presentation/widgets/common/page_selector.dart": "",
        "presentation/widgets/compress/quality_selector.dart": "",
        "presentation/widgets/convert/format_selector.dart": "",
        "presentation/widgets/merge/file_order_list.dart": "",
        "presentation/widgets/result/download_card.dart": "",
        "presentation/widgets/sign/signature_pad.dart": "",
        "presentation/widgets/sign/text_overlay.dart": "",
        "presentation/widgets/split/page_range_selector.dart": ""
    }
    
    for file_path, content in presentation_files.items():
        create_file(f"lib/{file_path}", content)
    
    # Providers directory
    create_directory("lib/providers")
    
    # Provider files
    provider_files = [
        "auth_provider.dart",
        "compress_provider.dart",
        "convert_provider.dart",
        "merge_provider.dart",
        "pdf_provider.dart",
        "protect_provider.dart",
        "repair_provider.dart",
        "sign_provider.dart",
        "split_provider.dart",
        "user_provider.dart"
    ]
    
    for file_name in provider_files:
        create_file(f"lib/providers/{file_name}")

if __name__ == "__main__":
    create_project_structure()
    print("Project structure created successfully!")