from typing import Optional
import numpy as np
import torch
from omni.isaac.core.prims import RigidPrimView
from omni.isaac.core.robots.robot import Robot
from omni.isaac.core.utils.nucleus import get_assets_root_path
from omni.isaac.core.utils.stage import add_reference_to_stage
from omni.isaac.core.utils.prims import *
from omni.isaac.core.utils.viewports import set_camera_view

from pxr import Gf, UsdGeom

import omni
import omni.graph.core as og

import numpy as np
import torch

from pxr import PhysxSchema

class Unitree(Robot):
    def __init__(
        self,
        prim_path: str,
        name: Optional[str] = "Unitree",
        usd_path: Optional[str] = None,
        translation: Optional[np.ndarray] = None,
        orientation: Optional[np.ndarray] = None,
    ) -> None:
        """[summary]
        """
        
        self._usd_path = usd_path
        self._name = name
    
        if self._usd_path is None:
            assets_root_path = get_assets_root_path()
            if assets_root_path is None:
                carb.log_error("Could not find nucleus server with /Isaac folder")
            self._usd_path = assets_root_path + "/Isaac/Robots/Unitree/go1.usd"
        add_reference_to_stage(self._usd_path, prim_path)
        
        super().__init__(
            prim_path=prim_path,
            name=name,
            translation=translation,
            orientation=orientation,
            articulation_controller=None,
        )

        self._dof_names = ["FL_hip_joint",
                            "RL_hip_joint",
                            "FR_hip_joint",
                            "RR_hip_joint",
                            "FL_thigh_joint",
                            "RL_thigh_joint",
                            "FR_thigh_joint",
                            "RR_thigh_joint",
                            "FL_calf_joint",
                            "RL_calf_joint",
                            "FR_calf_joint",
                            "RR_calf_joint"]
        # self.image_width = 640
        # self.image_height = 480

        # self.cameras = [
        #     # 0name, 1offset, 2orientation, 3hori aperture, 4vert aperture, 5projection, 6focal length, 7focus distance
        #     ("/camera_left", Gf.Vec3d(0.2693, 0.025, 0.067), (90, 0, -90), 21, 16, "perspective", 24, 400),
        #     ("/camera_right", Gf.Vec3d(0.2693, -0.025, 0.067), (90, 0, -90), 21, 16, "perspective", 24, 400),
        # ]
        # # after stage is defined
        # self.camera_graphs = []
        # self.camera_viewport_graphs = []
        # self._stage = omni.usd.get_context().get_stage()

        # # add cameras on the imu link
        # for i in range(len(self.cameras)):
        #     # add camera prim
        #     camera = self.cameras[i]
        #     camera_path = self.prim_path + "/imu_link" + camera[0]
        #     camera_prim = UsdGeom.Camera(self._stage.DefinePrim(camera_path, "Camera"))
        #     xform_api = UsdGeom.XformCommonAPI(camera_prim)
        #     xform_api.SetRotate(camera[2], UsdGeom.XformCommonAPI.RotationOrderXYZ)
        #     xform_api.SetTranslate(camera[1])
        #     camera_prim.GetHorizontalApertureAttr().Set(camera[3])
        #     camera_prim.GetVerticalApertureAttr().Set(camera[4])
        #     camera_prim.GetProjectionAttr().Set(camera[5])
        #     camera_prim.GetFocalLengthAttr().Set(camera[6])
        #     camera_prim.GetFocusDistanceAttr().Set(camera[7])

        #  # Create a graph to visualize the cameras directly in Isaac Sim
        #     keys = og.Controller.Keys
        #     graph_path = "/Viewport_" + camera[0].split("/")[-1]
        #     (camera_viewport_graph, _, _, _) = og.Controller.edit(
        #         {
        #             "graph_path": graph_path,
        #             "evaluator_name": "execution",
        #             "pipeline_stage": og.GraphPipelineStage.GRAPH_PIPELINE_STAGE_SIMULATION,
        #         },
        #         {
        #             keys.CREATE_NODES: [
        #                 ("OnPlaybackTick", "omni.graph.action.OnPlaybackTick"),
        #                 ("createViewport", "omni.isaac.core_nodes.IsaacCreateViewport"),
        #                 ("setViewportResolution", "omni.isaac.core_nodes.IsaacSetViewportResolution"),
        #                 ("getRenderProduct", "omni.isaac.core_nodes.IsaacGetViewportRenderProduct"),
        #                 ("setCamera", "omni.isaac.core_nodes.IsaacSetCameraOnRenderProduct"),
        #             ],
        #             keys.CONNECT: [
        #                 ("OnPlaybackTick.outputs:tick", "createViewport.inputs:execIn"),
        #                 ("createViewport.outputs:execOut", "setViewportResolution.inputs:execIn"),
        #                 ("createViewport.outputs:viewport", "setViewportResolution.inputs:viewport"),
        #                 ("createViewport.outputs:execOut", "getRenderProduct.inputs:execIn"),
        #                 ("createViewport.outputs:viewport", "getRenderProduct.inputs:viewport"),
        #                 ("getRenderProduct.outputs:execOut", "setCamera.inputs:execIn"),
        #                 ("getRenderProduct.outputs:renderProductPath", "setCamera.inputs:renderProductPath"),
        #             ],
        #             keys.SET_VALUES: [
        #                 ("createViewport.inputs:name", "Viewport " + str(i)),
        #                 ("setViewportResolution.inputs:height", int(self.image_height)),
        #                 ("setViewportResolution.inputs:width", int(self.image_width)),
        #             ],
        #         },
        #     )
        #     set_targets(
        #         prim=self._stage.GetPrimAtPath(graph_path + "/setCamera"),
        #         attribute="inputs:cameraPrim",
        #         target_prim_paths=[camera_path],
        #     )
        
        #     self.camera_viewport_graphs.append(camera_viewport_graph)

    @property
    def dof_names(self):
        return self._dof_names

    def set_go1_properties(self, stage, prim):
        for link_prim in prim.GetChildren():
            if link_prim.HasAPI(PhysxSchema.PhysxRigidBodyAPI): 
                rb = PhysxSchema.PhysxRigidBodyAPI.Get(stage, link_prim.GetPrimPath())
                rb.GetDisableGravityAttr().Set(False)
                rb.GetRetainAccelerationsAttr().Set(False)
                rb.GetLinearDampingAttr().Set(0.0)
                rb.GetMaxLinearVelocityAttr().Set(1000.0)
                rb.GetAngularDampingAttr().Set(0.0)
                rb.GetMaxAngularVelocityAttr().Set(64/np.pi*180)

    def prepare_contacts(self, stage, prim):
        for link_prim in prim.GetChildren():
            if link_prim.HasAPI(PhysxSchema.PhysxRigidBodyAPI): 
                if "_hip" not in str(link_prim.GetPrimPath()):
                    rb = PhysxSchema.PhysxRigidBodyAPI.Get(stage, link_prim.GetPrimPath())
                    rb.CreateSleepThresholdAttr().Set(0)
                    cr_api = PhysxSchema.PhysxContactReportAPI.Apply(link_prim)
                    cr_api.CreateThresholdAttr().Set(0)
