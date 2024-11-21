﻿#pragma once

Extern "C"

#define __USBIODEF_H__
Const USB_SUBMIT_URB = 0
Const USB_RESET_PORT = 1
Const USB_GET_ROOTHUB_PDO = 3
Const USB_GET_PORT_STATUS = 4
Const USB_ENABLE_PORT = 5
Const USB_GET_HUB_COUNT = 6
Const USB_CYCLE_PORT = 7
Const USB_GET_HUB_NAME = 8
Const USB_IDLE_NOTIFICATION = 9
Const USB_RECORD_FAILURE = 10
Const USB_GET_BUS_INFO = 264
Const USB_GET_CONTROLLER_NAME = 265
Const USB_GET_BUSGUID_INFO = 266
Const USB_GET_PARENT_HUB_INFO = 267
Const USB_GET_DEVICE_HANDLE = 268
Const USB_GET_DEVICE_HANDLE_EX = 269
Const USB_GET_TT_DEVICE_HANDLE = 270
Const USB_GET_TOPOLOGY_ADDRESS = 271
Const USB_IDLE_NOTIFICATION_EX = 272
Const USB_REQ_GLOBAL_SUSPEND = 273
Const USB_REQ_GLOBAL_RESUME = 274
Const USB_GET_HUB_CONFIG_INFO = 275
Const USB_REGISTER_COMPOSITE_DEVICE = 0
Const USB_UNREGISTER_COMPOSITE_DEVICE = 1
Const USB_REQUEST_REMOTE_WAKE_NOTIFICATION = 2
Const HCD_GET_STATS_1 = 255
Const HCD_DIAGNOSTIC_MODE_ON = 256
Const HCD_DIAGNOSTIC_MODE_OFF = 257
Const HCD_GET_ROOT_HUB_NAME = 258
Const HCD_GET_DRIVERKEY_NAME = 265
Const HCD_GET_STATS_2 = 266
Const HCD_DISABLE_PORT = 268
Const HCD_ENABLE_PORT = 269
Const HCD_USER_REQUEST = 270
Const HCD_TRACE_READ_REQUEST = 275
Const USB_GET_NODE_INFORMATION = 258
Const USB_GET_NODE_CONNECTION_INFORMATION = 259
Const USB_GET_DESCRIPTOR_FROM_NODE_CONNECTION = 260
Const USB_GET_NODE_CONNECTION_NAME = 261
Const USB_DIAG_IGNORE_HUBS_ON = 262
Const USB_DIAG_IGNORE_HUBS_OFF = 263
Const USB_GET_NODE_CONNECTION_DRIVERKEY_NAME = 264
Const USB_GET_HUB_CAPABILITIES = 271
Const USB_GET_NODE_CONNECTION_ATTRIBUTES = 272
Const USB_HUB_CYCLE_PORT = 273
Const USB_GET_NODE_CONNECTION_INFORMATION_EX = 274
Const USB_RESET_HUB = 275
Const USB_GET_HUB_CAPABILITIES_EX = 276
Const USB_GET_HUB_INFORMATION_EX = 277
Const USB_GET_PORT_CONNECTOR_PROPERTIES = 278
Const USB_GET_NODE_CONNECTION_INFORMATION_EX_V2 = 279
#define GUID_CLASS_USBHUB GUID_DEVINTERFACE_USB_HUB
#define GUID_CLASS_USB_DEVICE GUID_DEVINTERFACE_USB_DEVICE
#define GUID_CLASS_USB_HOST_CONTROLLER GUID_DEVINTERFACE_USB_HOST_CONTROLLER
#define FILE_DEVICE_USB FILE_DEVICE_UNKNOWN
'#define USB_CTL(id) CTL_CODE(FILE_DEVICE_USB, (id), METHOD_BUFFERED, FILE_ANY_ACCESS)
'#define USB_KERNEL_CTL(id) CTL_CODE(FILE_DEVICE_USB, (id), METHOD_NEITHER, FILE_ANY_ACCESS)
'#define USB_KERNEL_CTL_BUFFERED(id) CTL_CODE(FILE_DEVICE_USB, (id), METHOD_BUFFERED, FILE_ANY_ACCESS)

' TODO: DEFINE_GUID (GUID_DEVINTERFACE_USB_HUB, 0xf18a0e88, 0xc30c, 0x11d0, 0x88, 0x15, 0x00, 0xa0, 0xc9, 0x06, 0xbe, 0xd8);
' TODO: DEFINE_GUID (GUID_DEVINTERFACE_USB_DEVICE, 0xa5dcbf10, 0x6530, 0x11d2, 0x90, 0x1f, 0x00, 0xc0, 0x4f, 0xb9, 0x51, 0xed);
' TODO: DEFINE_GUID (GUID_DEVINTERFACE_USB_HOST_CONTROLLER, 0x3abf6f2d, 0x71c4, 0x462a, 0x8a, 0x92, 0x1e, 0x68, 0x61, 0xe6, 0xaf, 0x27);
' TODO: DEFINE_GUID (GUID_USB_WMI_STD_DATA, 0x4e623b20, 0xcb14, 0x11d1, 0xb3, 0x31, 0x00, 0xa0, 0xc9, 0x59, 0xbb, 0xd2);
' TODO: DEFINE_GUID (GUID_USB_WMI_STD_NOTIFICATION, 0x4e623b20, 0xcb14, 0x11d1, 0xb3, 0x31, 0x00, 0xa0, 0xc9, 0x59, 0xbb, 0xd2);
'type USB_IDLE_CALLBACK as function(byval Context as PVOID) as VOID

'Type _USB_IDLE_CALLBACK_INFO
'	IdleCallback As USB_IDLE_CALLBACK
'	IdleContext As PVOID
'End Type
'
'Type USB_IDLE_CALLBACK_INFO As _USB_IDLE_CALLBACK_INFO
'Type PUSB_IDLE_CALLBACK_INFO As _USB_IDLE_CALLBACK_INFO Ptr

End Extern
