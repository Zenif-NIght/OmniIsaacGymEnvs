from typing import Optional

from omni.isaac.core.articulations import ArticulationView
from omni.isaac.core.prims import RigidPrimView


class UnitreeView(ArticulationView):
    def __init__(
        self,
        prim_paths_expr: str,
        name: Optional[str] = "UnitreeView",
        track_contact_forces=False,
        prepare_contact_sensors=False
    ) -> None:
        """[summary]
        """

        super().__init__(
            prim_paths_expr=prim_paths_expr,
            name=name,
            reset_xform_properties=False
        )
        self._knees = RigidPrimView(prim_paths_expr="/World/envs/.*/Go1/.*_thigh",
            name="knees_view", reset_xform_properties=False, track_contact_forces=track_contact_forces, prepare_contact_sensors=prepare_contact_sensors)
        self._base = RigidPrimView(prim_paths_expr="/World/envs/.*/Go1/base",
            name="base_view", reset_xform_properties=False, track_contact_forces=track_contact_forces, prepare_contact_sensors=prepare_contact_sensors)

    def get_knee_transforms(self):
        return self._knees.get_world_poses()

    def is_knee_below_threshold(self, threshold, ground_heights=None):
        knee_pos, _ = self._knees.get_world_poses()
        knee_heights = knee_pos.view((-1, 4, 3))[:, :, 2]
        if ground_heights is not None:
            knee_heights -= ground_heights
        return (knee_heights[:, 0] < threshold) | (knee_heights[:, 1] < threshold) | (knee_heights[:, 2] < threshold) | (knee_heights[:, 3] < threshold)

    def is_base_below_threshold(self, threshold, ground_heights):
        base_pos, _ = self.get_world_poses()
        base_heights = base_pos[:, 2]
        base_heights -= ground_heights
        return (base_heights[:] < threshold)