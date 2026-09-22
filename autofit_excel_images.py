import win32com.client as win32
import os, sys

def autofit_images_in_excel(xlsx_filename="All_Post_Offices_Image_Template.xlsx"):
    abs_path = os.path.abspath(xlsx_filename)
    if not os.path.exists(abs_path):
        print(f"File not found: {abs_path}")
        return
        
    import pythoncom
    try:
        pythoncom.CoInitialize()
    except Exception:
        pass
    xl = win32.Dispatch("Excel.Application")
    xl.Visible = False
    xl.DisplayAlerts = False
    
    try:
        wb = xl.Workbooks.Open(abs_path)
        ws = wb.Worksheets(1)
        count = 0
        for shp in ws.Shapes:
            # msoPicture = 13, msoLinkedPicture = 11, msoMedia = 16
            if shp.Type in (13, 11, 16) or "Picture" in shp.Name or "Image" in shp.Name:
                cell = shp.TopLeftCell
                if cell.Column == 6:  # Column F (Reference Image / Document)
                    shp.LockAspectRatio = -1  # True
                    
                    # Target box with 8pt padding
                    target_h = max(cell.Height - 12, 20)
                    target_w = max(cell.Width - 12, 20)
                    
                    shp.Height = target_h
                    if shp.Width > target_w:
                        shp.Width = target_w
                        
                    # Center inside cell
                    shp.Top = cell.Top + (cell.Height - shp.Height) / 2
                    shp.Left = cell.Left + (cell.Width - shp.Width) / 2
                    count += 1
                    
        wb.Save()
        print(f"Success! Auto-fitted {count} pasted image(s) to fit inside cell boxes.")
    except Exception as e:
        print(f"Error fitting images: {e}")
    finally:
        wb.Close(False)
        xl.Quit()

if __name__ == "__main__":
    file_name = sys.argv[1] if len(sys.argv) > 1 else "All_Post_Offices_Image_Template.xlsx"
    autofit_images_in_excel(file_name)
